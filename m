From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 10:37:38 -0800
Message-ID: <1357843058.27446.2406.camel@edumazet-glaptop>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>
	 ,<1357750898.27446.33.camel@edumazet-glaptop>
	 ,<1357751372.27446.40.camel@edumazet-glaptop>
	 ,<1357801149.27446.1142.camel@edumazet-glaptop>
	 <DUB107-W210F9409862AAA949CB15ED2A0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lukas Tribus <luky-37@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:35506 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab3AJShl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 13:37:41 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so456221pbc.18
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 10:37:40 -0800 (PST)
In-Reply-To: <DUB107-W210F9409862AAA949CB15ED2A0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-10 at 19:27 +0100, Lukas Tribus wrote:
> Hi Eric,
> 
> this is probably a dumb question ... but since the fix is in net/ipv4/tcp.c I was asking myself if this can affect IPv6 as well?
> 

Yes it can, net/ipv4 contains generic TCP code.
