From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] econet: kill unnecessary spin_lock_init()
Date: Sat, 28 Aug 2010 15:37:21 -0700 (PDT)
Message-ID: <20100828.153721.59667226.davem@davemloft.net>
References: <1282963316-29938-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, julia@diku.dk,
	netdev@vger.kernel.org
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46239
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831Ab0H1WhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 18:37:05 -0400
In-Reply-To: <1282963316-29938-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 28 Aug 2010 11:41:56 +0900

> The spinlock aun_queue_lock is initialized statically. It is unnecessary
> to initialize by spin_lock_init() at module load time.
> 
> This is detected by the semantic patch.
 ...
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Julia Lawall <julia@diku.dk>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org

Applied.
