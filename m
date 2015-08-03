From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Fix resource leaks in vortex_open
Date: Mon, 03 Aug 2015 15:21:50 -0700 (PDT)
Message-ID: <20150803.152150.1891006093180585787.davem@davemloft.net>
References: <1438571892-28318-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, klassert@mathematik.tu-chemnitz.de,
	paul.gortmaker@windriver.com, dvlasenk@redhat.com,
	linux@rasmusvillemoes.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: baijiaju1990@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438571892-28318-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Mon,  3 Aug 2015 11:18:12 +0800

> When vortex_up is failed, the skb buffers allocated by __netdev_alloc_skb
> in vortex_open are not released, which may cause resource leaks.
> This bug has been submitted before.
> This patch modifies the error handling code to fix it.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Applied, thanks.
