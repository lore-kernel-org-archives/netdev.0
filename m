From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/12] BKL: Remove BKL from capifs
Date: Fri, 17 Sep 2010 16:35:30 -0700 (PDT)
Message-ID: <20100917.163530.266095048.davem@davemloft.net>
References: <1284659185-8942-1-git-send-email-arnd@arndb.de>
	<1284659185-8942-7-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284659185-8942-7-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 16 Sep 2010 19:46:19 +0200

> The BKL is only used in fill_super, which is  protected by the superblocks
> s_umount rw_semaphore. Therefore it is safe to remove the BKL entirely.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: netdev@vger.kernel.org

I've searched Linus's tree, net-2.6, and net-next-2.6 and I cannot
find one reference to lock_kernel() in drivers/isdn/capi/capifs.c
in any of them.

What did you write this patch against?
