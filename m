From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] 82596: do not panic on out of memory
Date: Sat, 10 Jul 2010 19:42:23 -0700 (PDT)
Message-ID: <20100710.194223.15248752.davem@davemloft.net>
References: <1278678323-6848-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, jpirko@redhat.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	andre.goddard@gmail.com, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752220Ab0GKCmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 22:42:08 -0400
In-Reply-To: <1278678323-6848-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Fri,  9 Jul 2010 16:25:22 +0400

> If dev_alloc_skb() failed then free already allocated skbs.
> remove_rx_bufs() can be called multiple times, so set rbd->skb to NULL
> to avoid double free. remove_rx_bufs() was moved upwards to be seen by
> init_rx_bufs().
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied to net-next-2.6
