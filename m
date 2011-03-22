From: David Miller <davem@davemloft.net>
Subject: Re: [held lock freed] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 18:18:16 -0700 (PDT)
Message-ID: <20110321.181816.15242871.davem@davemloft.net>
References: <201103211550.10694.arnd@arndb.de>
	<1300719332.2884.370.camel@edumazet-laptop>
	<201103211622.40851.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mingo@elte.hu,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	a.p.zijlstra@chello.nl, tglx@linutronix.de
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37977
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755227Ab1CVBRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:17:38 -0400
In-Reply-To: <201103211622.40851.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 21 Mar 2011 16:22:40 +0100

> net/appletalk: fix atalk_release use after free
> 
> The BKL removal in appletalk introduced a use-after-free problem,
> where atalk_destroy_socket frees a sock, but we still release
> the socket lock on it.
> 
> An easy fix is to take an extra reference on the sock and sock_put
> it when returning from atalk_release.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
