From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] [oops] gre/gro oops in skb_gro_receive+0x118/0x453
Date: Fri, 16 May 2014 11:04:39 -0700
Message-ID: <1400263479.5367.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140516104014.607d2d0f@vostro>
	 <1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516173443.0b40157e@vostro>
	 <1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516194037.4486cd63@vostro>
	 <1400259027.7973.211.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516200112.114cf1bb@vostro>
	 <1400260430.7973.222.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516203835.5941ea3f@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:40173 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754949AbaEPSEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 14:04:41 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so2930276pbc.29
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 11:04:40 -0700 (PDT)
In-Reply-To: <20140516203835.5941ea3f@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 20:38 +0300, Timo Teras wrote:


> Unfortunately, I do not have fully matching identical .s, or debug
> built kernel. I can do that on Monday if this does not help.
> 
> Additionally, the .s file from separate, but similar build, that seems
> to have matching assembly is as follows:

Thanks a lot, I found the bug, its yet another case of skb->cb[] being
not clean ;)

I am testing a patch atm.
