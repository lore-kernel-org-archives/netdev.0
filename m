From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.13-rc6] net/802/tr: use interrupt-safe locking
Date: Wed, 17 Aug 2005 15:00:47 -0700 (PDT)
Message-ID: <20050817.150047.64537724.davem@davemloft.net>
References: <20050817204959.GA20186@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-tr@linuxtr.net, mikep@linuxtr.net,
	jgarzik@pobox.com, fubar@us.ibm.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751280AbVHQWBO@vger.kernel.org>
To: linville@tuxdriver.com
In-Reply-To: <20050817204959.GA20186@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 17 Aug 2005 16:49:59 -0400

> Change operations on rif_lock from spin_{un}lock_bh to
> spin_{un}lock_irq{save,restore} equivalents.  Some of the
> rif_lock critical sections are called from interrupt context via
> tr_type_trans->tr_add_rif_info.  The TR NIC drivers call tr_type_trans
> from their packet receive handlers.

Applied, I'll try to get this into 2.6.13, but it may have
to wait for 2.6.14
