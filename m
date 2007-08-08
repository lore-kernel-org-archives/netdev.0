From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Wed, 8 Aug 2007 21:42:47 +0800
Message-ID: <20070808134247.GA9942@gondor.apana.org.au>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
	<20070808.034900.85820906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, jeff@garzik.org,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, hadi@cyberus.ca,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070808.034900.85820906.davem@davemloft.net>
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

On Wed, Aug 08, 2007 at 03:49:00AM -0700, David Miller wrote:
> 
> Not because I think it obviates your work, but rather because I'm
> curious, could you test a TSO-in-hardware driver converted to
> batching and see how TSO alone compares to batching for a pure
> TCP workload?

You could even lower the bar by disabling TSO and enabling
software GSO.

> I personally don't think it will help for that case at all as
> TSO likely does better job of coalescing the work _and_ reducing
> bus traffic as well as work in the TCP stack.

I agree.  I suspect the bulk of the effort is in getting
these skb's created and processed by the stack so that by
the time that they're exiting the qdisc there's not much
to be saved anymore.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
