From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Wed, 22 Aug 2007 09:41:52 +0530
Message-ID: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>
References: <20070821.115143.23013721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070821.115143.23013721.davem@davemloft.net>
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

David Miller <davem@davemloft.net> wrote on 08/22/2007 12:21:43 AM:

> From: jamal <hadi@cyberus.ca>
> Date: Tue, 21 Aug 2007 08:30:22 -0400
>
> > On Tue, 2007-21-08 at 00:18 -0700, David Miller wrote:
> >
> > > Using 16K buffer size really isn't going to keep the pipe full enough
> > > for TSO.
> >
> > Why the comparison with TSO (or GSO for that matter)?
>
> Because TSO does batching already, so it's a very good
> "tit for tat" comparison of the new batching scheme
> vs. an existing one.

I am planning to do more testing on your suggestion over the
weekend, but I had a comment. Are you saying that TSO and
batching should be mutually exclusive so hardware that doesn't
support TSO (like IB) only would benefit?

But even if they can co-exist, aren't cases like sending
multiple small skbs better handled with batching?

Thanks,

- KK
