From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/via-rhine: Fix scheduling while atomic bugs
Date: Wed, 23 Dec 2009 21:54:48 -0800 (PST)
Message-ID: <20091223.215448.241930752.davem@davemloft.net>
References: <20091222150045.GA5355@wrars-comp.wrarsdomain>
	<20091222152658.GA16043@core.hellgate.ch>
	<20091222173641.GA3093@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, wrar@altlinux.org, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755333AbZLXFys@vger.kernel.org>
In-Reply-To: <20091222173641.GA3093@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 22 Dec 2009 18:36:42 +0100

> There are BUGs "scheduling while atomic" triggered by the timer
> rhine_tx_timeout(). They are caused by calling napi_disable() (with
> msleep()). This patch fixes it by moving most of the timer content to
> the workqueue function (similarly to other drivers, like tg3), with
> spin_lock() changed to BH version.
> 
> Additionally, there is spin_lock_irq() moved in rhine_close() to
> exclude napi_disable() etc., also tg3's way.
> 
> Reported-by: Andrey Rahmatullin <wrar@altlinux.org>
> Tested-by: Andrey Rahmatullin <wrar@altlinux.org>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks!
