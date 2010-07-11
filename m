From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] 82596: free resources on error
Date: Sat, 10 Jul 2010 19:42:30 -0700 (PDT)
Message-ID: <20100710.194230.242142024.davem@davemloft.net>
References: <1278678340-6889-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, jpirko@redhat.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	andre.goddard@gmail.com, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39882
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753240Ab0GKCmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 22:42:16 -0400
In-Reply-To: <1278678340-6889-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Fri,  9 Jul 2010 16:25:40 +0400

> IRQ 56 was not freed anywhere (neither in i596_open() on error nor in
> i596_close()), rx_bufs were not freed if init_i596_mem() fails,
> netif_stop_queue() was not called.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied to net-next-2.6
