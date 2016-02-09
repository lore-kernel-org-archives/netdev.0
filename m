From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: Fixes for rockchip EMAC
Date: Tue,  9 Feb 2016 18:20:37 +0300
Message-ID: <1455031240-29385-1-git-send-email-al.kochet@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"'David S. Miller'" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Here is a set of 3 patches what fix koops, memory leak and
rockchip EMAC hang. Tested on radxarock lite.

[PATCH 1/3] net: arc_emac: fix koops caused by sk_buff free
[PATCH 2/3] net: arc_emac: reset txbd_curr and txbd_dirty pointers
[PATCH 3/3] net: arc_emac: fix sk_buff leak
