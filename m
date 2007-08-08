From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Wed, 08 Aug 2007 15:22:40 -0700 (PDT)
Message-ID: <20070808.152240.56052317.davem@davemloft.net>
References: <20070808.034900.85820906.davem@davemloft.net>
	<20070808134247.GA9942@gondor.apana.org.au>
	<1186586075.5155.27.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, mcarlson@broadcom.com, netdev@vger.kernel.org,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, jeff@garzik.org,
	shemminger@linux-foundation.org, kaber@trash.net, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1186586075.5155.27.camel@localhost>
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

From: jamal <hadi@cyberus.ca>
Date: Wed, 08 Aug 2007 11:14:35 -0400

> pktgen shows a clear win if you test the driver path - which is what
> you should test because thats where the batching changes are.

The driver path, however, does not exist on an island and what
we care about is the final result with the changes running
inside the full system.

So, to be honest, besides for initial internal development
feedback, the isolated tests only have minimal merit and
it's the full protocol tests that are really interesting.
