From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge: Respect call-iptables sysctls everywhere
Date: Sun, 5 Oct 2014 18:18:04 +0800
Message-ID: <20141005101804.GA15592@gondor.apana.org.au>
References: <1412384670-17794-1-git-send-email-fw@strlen.de>
 <20141004035606.GA8228@gondor.apana.org.au>
 <20141004100413.GA1241@breakpoint.cc>
 <20141004135508.GA10705@gondor.apana.org.au>
 <20141004141802.GA10878@gondor.apana.org.au>
 <20141004180647.GB1241@breakpoint.cc>
 <20141005035343.GA13696@gondor.apana.org.au>
 <20141005091343.GA11246@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, bsd@redhat.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141005091343.GA11246@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 05, 2014 at 11:13:43AM +0200, Florian Westphal wrote:
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > On Sat, Oct 04, 2014 at 08:06:47PM +0200, Florian Westphal wrote:
> > >
> > > Fair enough.  We lose frag_max_size information from ipv4 defrag,
> > 
> > While reviewing this code it occured to me that we have a serious
> > bug in that call-iptables sysctls aren't even respected in FORWARD
> > and POST_ROUTING.  Here is a patch that fixes this.
> 
> Upcalls to iptables in FORWARD/POSTROUTING depend on skb->nf_bridge
> being set up, which only happens when call-iptables=1.

Good point.  So we can discard this patch.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
