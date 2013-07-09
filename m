From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: caif: fix wrong rtnl_is_locked() usage
Date: Tue, 09 Jul 2013 12:56:32 -0700 (PDT)
Message-ID: <20130709.125632.1573031651619706332.davem@davemloft.net>
References: <20130708072304.20622.60798.stgit@zurg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry.tarnyagin@lockless.no
To: khlebnikov@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130708072304.20622.60798.stgit@zurg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 08 Jul 2013 11:23:04 +0400

> rtnl_is_locked() doesn't check who holds this lock, it just tells that it's
> locked right now. if caif::ldisc_close really can be called under rtrnl_lock
> then it should release net device in other context because there is no way
> to grab rtnl_lock without deadlock.
> 
> This patch adds work which releases these devices. Also this patch fixes calling
> dev_close/unregister_netdevice without rtnl_lock from caif_ser_exit().
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Applied.
