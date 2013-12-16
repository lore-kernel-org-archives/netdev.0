From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next] tcp: use zero-window when free_space is low
Date: Mon, 16 Dec 2013 05:41:20 -0800
Message-ID: <1387201280.19078.223.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387192557-9816-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:60245 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699Ab3LPNlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 08:41:23 -0500
Received: by mail-pa0-f46.google.com with SMTP id kl14so2929012pab.5
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 05:41:21 -0800 (PST)
In-Reply-To: <1387192557-9816-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 12:15 +0100, Florian Westphal wrote:
> Currently the kernel tries to announce a zero window when free_space
> is below the current receiver mss estimate.
> 
> When a sender is transmitting small packets, the receiver might be
> unable to shrink the receive window, because
> a) we cannot withdraw already-commited receive window, and,
> b) we have to round the current rwin up to a multiple of the wscale factor,
>    else we would shrink the current window.
> 
> This causes the receive buffer to fill up until the rmem limit is hit.
> When this happens, we start dropping packets.

I do not really understand the issue.
Do you have a packetdrill test to demonstrate it ?

Thanks !
