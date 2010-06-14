From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fragment: add fast path
Date: Mon, 14 Jun 2010 08:40:37 +0200
Message-ID: <1276497637.2478.1.camel@edumazet-laptop>
References: <1276470995-21713-1-git-send-email-xiaosuo@gmail.com>
	 <1276493743.2448.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52152 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab0FNGkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 02:40:41 -0400
Received: by wyb40 with SMTP id 40so3460917wyb.19
        for <netdev@vger.kernel.org>; Sun, 13 Jun 2010 23:40:39 -0700 (PDT)
In-Reply-To: <1276493743.2448.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I am not sure why we need "struct inet_skb_parm h;" field in struct
> ipfrag_skb_cb... 
> 
> I probably need to wakeup this monday morning ?
> 
> Untested patch follows, only compiled.
> 

Oh well, I see light now I woke up ;)

> [PATCH] frags: Remove unecessary bits
> 
> While trying to move 'offset' to the beginning of frag CB, I found
> inet_skb_parm field was unused.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Wrong patch of course.

We need some comment or document better why its there..



