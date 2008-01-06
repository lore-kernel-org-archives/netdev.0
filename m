From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Sat, 5 Jan 2008 22:25:18 -0500
Message-ID: <200801052225.19165.paul.moore@hp.com>
References: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, acme@redhat.com,
	latten@us.ibm.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"Ilpo J??rvinen" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:42173 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbYAFDZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 22:25:28 -0500
In-Reply-To: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 05 January 2008 7:29:35 pm Herbert Xu wrote:
> Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > Signed-off-by: Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>
>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> > #ifdef CONFIG_AUDITSYSCALL
> > -static inline void xfrm_audit_helper_sainfo(struct xfrm_state *x,
> > -                                           struct audit_buffer
> > *audit_buf) +static void xfrm_audit_helper_sainfo(struct xfrm_state *x,
> > +                                    struct audit_buffer *audit_buf)
>
> We should never use inline except when it's on the fast path and this
> is definitely not a fast path.  If a function ends up being called
> just once the compiler will most likely inline it anyway, making the
> use of the keyword inline redundant.

For the record the inline was there before the audit patch I submitted ... 
then again, I suppose I could have removed the inline while I was at it, I 
just didn't notice it.  Sorry about that.

Thanks for fixing this guys.

-- 
paul moore
linux security @ hp
