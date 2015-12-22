From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 -next 3/3] tcp: honour SO_BINDTODEVICE for TW_RST
 case too
Date: Tue, 22 Dec 2015 14:06:19 -0500
Message-ID: <1450811179.8474.135.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450729766-14926-1-git-send-email-fw@strlen.de>
	 <1450729766-14926-4-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:36005 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463AbbLVTGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 14:06:20 -0500
Received: by mail-qk0-f174.google.com with SMTP id t125so152544515qkh.3
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 11:06:20 -0800 (PST)
In-Reply-To: <1450729766-14926-4-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-12-21 at 21:29 +0100, Florian Westphal wrote:
> Hannes points out that when we generate tcp reset for timewait sockets we
> pretend we found no socket and pass NULL sk to tcp_vX_send_reset().
> 
> Make it cope with inet tw sockets and then provide tw sk.
> 
> This makes RSTs appear on correct interface when SO_BINDTODEVICE is used.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Florian !
