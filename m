From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [netfilter-core] [NETFILTER] Apply IPsec to ipt_REJECT packets
Date: Wed, 24 Nov 2004 00:32:11 -0800
Message-ID: <20041124003211.54807ff8.davem@davemloft.net>
References: <20041123084225.GA3514@gondor.apana.org.au>
	<41A37EC0.8010901@trash.net>
	<20041123211630.GA9805@gondor.apana.org.au>
	<41A3AF41.4010700@trash.net>
	<20041123221900.GA10099@gondor.apana.org.au>
	<41A3E9D6.9060904@trash.net>
	<20041124062747.GA13522@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com, coreteam@netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041124062747.GA13522@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Nov 2004 17:27:47 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Nov 24, 2004 at 02:54:30AM +0100, Patrick McHardy wrote:
> >
> > >	if (rt->u.dst.error) {
> > >@@ -82,6 +88,15 @@
> > >		rt = NULL;
> > >
> > ^ you should return here so xfrm_lookup isn't called without a dst_entry 
> > below.
> 
> Good point.  Fixed in the following patch.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Thanks for all your help, Patrick.

Applied for 2.6.10, thanks everyone.
