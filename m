From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window
 transitions
Date: Tue, 25 Feb 2014 04:24:29 -0800
Message-ID: <1393331069.2316.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392674268-26005-1-git-send-email-fw@strlen.de>
	 <20140224.191410.698948363517952588.davem@davemloft.net>
	 <20140225082341.GA9965@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42431 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101AbaBYMYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 07:24:31 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so7995241pab.21
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 04:24:30 -0800 (PST)
In-Reply-To: <20140225082341.GA9965@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-25 at 09:23 +0100, Florian Westphal wrote:
> David Miller <davem@davemloft.net> wrote:
 
> > What is happening with this patch?  The discussion just died out.
> 
> I guess Eric is busy with TCP usec timer resolution changes.
> You can mark the patch as defered if you want; I can re-send it for
> 3.16 if needed.

Well, I was waiting you resend it using Hannes feedback ;)

That is using NET_INC_STATS() instead of NET_INC_STATS_BH()

I am sending the cleanup for LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES
immediately.
