From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: ethernet: mediatek: avoid potential
 invalid memory access
Date: Mon, 24 Jul 2017 13:44:08 -0700 (PDT)
Message-ID: <20170724.134408.1220348031618074380.davem@davemloft.net>
References: <e5eab7347d0918d7f2aff2951e66f93ef19594cd.1500727290.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e5eab7347d0918d7f2aff2951e66f93ef19594cd.1500727290.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Sat, 22 Jul 2017 20:45:55 +0800

> From: Sean Wang <sean.wang@mediatek.com>
> 
> Potential dangerous invalid memory might be accessed if invalid mac value
> reflected from the forward port field in rxd4 caused by possible potential
> hardware defects. So added a simple sanity checker to avoid the kind of
> situation happening.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> Acked-by: John Crispin <john@phrozen.org>

Applied.
