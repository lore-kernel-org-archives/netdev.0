From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: fix skb_page_frag_refill() kerneldoc
Date: Mon, 08 Sep 2014 04:22:08 -0700
Message-ID: <1410175328.11872.97.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410174000.11872.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <540D8D3C.9080202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:36072 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbaIHLWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 07:22:10 -0400
Received: by mail-pd0-f179.google.com with SMTP id g10so7602084pdj.24
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 04:22:10 -0700 (PDT)
In-Reply-To: <540D8D3C.9080202@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 15:04 +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 9/8/2014 3:00 PM, Eric Dumazet wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> 
> > In commit d9b2938aabf7 ("net: attempt a single high order allocation)
> > I forgot to update kerneldoc, as @prio parameter was renamed to @gfp
> 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >   net/core/sock.c |    2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index d372b4bd3f99..9c3f823e76a9 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1866,7 +1866,7 @@ EXPORT_SYMBOL(sock_alloc_send_skb);
> >    * skb_page_frag_refill - check that a page_frag contains enough room
> >    * @sz: minimum size of the fragment we want to get
> >    * @pfrag: pointer to page_frag
> > - * @prio: priority for memory allocation
> > + * @gfp: priority for memory allocation
> 
>     'gfp' is not priority, it's just flags.

This is the usual wording for this in net/core

I changed the name of the argument, not its meaning.

$ scripts/kernel-doc net/core/sock.c >/dev/null
Warning(net/core/sock.c:1874): No description found for parameter 'gfp'
Warning(net/core/sock.c:1874): Excess function parameter 'prio'
description in 'skb_page_frag_refill'

Feel free to submit a net-next patch to change net/core occurrences.

Thanks
