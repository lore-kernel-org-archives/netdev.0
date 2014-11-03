From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP out of memory - possible bug [3.18.0-rc3] / sched?
Date: Mon, 03 Nov 2014 11:41:44 -0800
Message-ID: <1415043704.1005.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5457D095.9070502@qdot.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tomasz Mloduchowski <q@qdot.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:46087 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbaKCTlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:41:46 -0500
Received: by mail-ie0-f169.google.com with SMTP id tr6so6093745ieb.28
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 11:41:45 -0800 (PST)
In-Reply-To: <5457D095.9070502@qdot.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 19:59 +0100, Tomasz Mloduchowski wrote:
> Hi List,
> 
> I hope this is the right place to report a networking issue with
> 3.18.0-rc2 and 3.18.0-rc3 - under heavy P2P load (tested both
> rtorrent/libtorrent and bitcoind, so not protocol-specific), the system
> quickly exhausts tcp_mem limits in a very strange sequence of events.
> 
> It might be scheduler or networking subsystem related.
> 
> It's 100% reproducible on my system, first observed under 3.18.0-rc2.
> 

Sounds a perfect case for a bisection maybe ?
