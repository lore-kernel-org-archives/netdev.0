From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] add missing flow_cache_genid update to
 xfrm_policy_delete()
Date: Mon, 9 Aug 2004 16:51:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809165115.5eff4e98.davem@redhat.com>
References: <20040805071459.GA31551@gate.ebshome.net>
	<E1BsgwG-0000O6-00@gondolin.me.apana.org.au>
	<20040805160144.GA28597@gate.ebshome.net>
	<20040805212421.GA4689@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ebs@ebshome.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040805212421.GA4689@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Aug 2004 07:24:21 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Aug 05, 2004 at 09:01:44AM -0700, Eugene Surovegin wrote:
> > On Thu, Aug 05, 2004 at 10:01:40PM +1000, Herbert Xu wrote:
> > > Please add a dir < XFRM_POLICY_MAX check before the atomic_inc so that
> > > dying sockets with policies don't blow away the flow cache.
> > 
> > Ohh, you're right :). Updated patch follows.
> 
> Thanks.
> 
> Dave, please apply Eugene's patch to fix hard policy expiration.

Done.

Thanks.
