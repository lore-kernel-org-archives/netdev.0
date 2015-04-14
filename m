From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: Re: [PATCH] ip_forward: Drop frames with attached skb->sk
Date: Tue, 14 Apr 2015 08:18:40 +0200
Message-ID: <1428992320.6812.20.camel@googlemail.com>
References: <1428990724.6812.8.camel@googlemail.com>
	 <20150413230714.2cf40794@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Poehn <sebastian.poehn@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de, eric.dumazet@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34439 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbbDNGSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 02:18:42 -0400
Received: by widjs5 with SMTP id js5so80402010wid.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 23:18:41 -0700 (PDT)
In-Reply-To: <20150413230714.2cf40794@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-13 at 23:07 -0700, Stephen Hemminger wrote:
> On Tue, 14 Apr 2015 07:52:04 +0200
> Sebastian Poehn <sebastian.poehn@gmail.com> wrote:
> 
> >  
> > +	/* this should happen neither */
> > +	if (unlikely(skb->sk))
> > +		goto drop;
> > +
> 
> With gcc, all goto's are already treated as unlikely().

Thanks for that recommendation. But before I re-cook: What about Clang
and ICC?
