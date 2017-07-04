From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: mediatek: fixed deadlock captured by
 lockdep
Date: Tue, 04 Jul 2017 01:43:57 -0700 (PDT)
Message-ID: <20170704.014357.2098420534003373919.davem@davemloft.net>
References: <96f5bb5018167e8d327d7613674cc1f2a81fe99f.1499137698.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <96f5bb5018167e8d327d7613674cc1f2a81fe99f.1499137698.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Tue, 4 Jul 2017 11:17:36 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> Lockdep found an inconsistent lock state when mtk_get_stats64 is called
> in user context while NAPI updates MAC statistics in softirq.
> 
> Use spin_trylock_bh/spin_unlock_bh fix following lockdep warning.
 ...
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

Good catch, applied, thanks.
