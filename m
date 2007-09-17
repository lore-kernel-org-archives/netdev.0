From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 0/10 REV5] Implement skb batching and
	support in IPoIB/E1000
Date: Mon, 17 Sep 2007 10:16:02 +0530
Message-ID: <OFEC575300.46D36636-ON65257359.001958ED-65257359.001A303C@in.ibm.com>
References: <20070916.192502.123919711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, shemminger@linux-foundation.org,
	kaber@trash.net, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070916.192502.123919711.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

[Removing Jeff as requested from thread :) ]

Hi Dave,

David Miller <davem@davemloft.net> wrote on 09/17/2007 07:55:02 AM:

> From: jamal <hadi@cyberus.ca>
> Date: Sun, 16 Sep 2007 22:14:21 -0400
>
> > I still think this work - despite my vested interest - needs more
> > scrutiny from a performance perspective.
>
> Absolutely.
>
> There are tertiary issues I'm personally interested in, for example
> how well this stuff works when we enable software GSO on a non-TSO
> capable card.
>
> In such a case the GSO segment should be split right before we hit the
> driver and then all the sub-segments of the original GSO frame batched
> in one shot down to the device driver.
>
> In this way you'll get a large chunk of the benefit of TSO without
> explicit hardware support for the feature.
>
> There are several cards (some even 10GB) that will benefit immensely
> from this.

I have tried this on ehca which does not support TSO. I added GSO flag at
the ipoib layer (and that resulted in a panic/fix that is mentioned in
this patchset). I will re-run tests for this and submit results.

Thanks,

- KK
