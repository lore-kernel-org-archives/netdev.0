From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] slip: fix spinlock variant
Date: Sun, 27 Apr 2014 23:35:56 -0400 (EDT)
Message-ID: <20140427.233556.452938883341708431.davem@davemloft.net>
References: <534D31EF.6050107@hartkopp.net>
	<534D3748.6060602@pengutronix.de>
	<535C0688.604@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nautsch2@gmail.com, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, alexander.stein@systec-electronic.com
To: socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <535C0688.604@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Sat, 26 Apr 2014 21:18:32 +0200

> With commit cc9fa74e2a ("slip/slcan: added locking in wakeup function") a
> formerly missing locking was added to slip.c and slcan.c by Andre Naujoks.
> 
> Alexander Stein contributed the fix 367525c8c2 ("can: slcan: Fix spinlock
> variant") as the kernel lock debugging advised to use spin_lock_bh() instead
> of just using spin_lock().
> 
> This fix has to be applied to the same code section in slip.c for the same
> reason too.
> 
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied and queued up for -stable, thanks.
