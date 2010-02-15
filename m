From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm v2 0/5] ssb: replace the ssb_dma API with the generic DMA API
Date: Tue, 16 Feb 2010 00:04:05 +0900
Message-ID: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seems that there is a good chance of the inclusion so here's the
second version that finishes all the conversion.


=
 drivers/net/b44.c                    |  144 +++++++++++++++----------------
 drivers/net/wireless/b43/dma.c       |   65 +++++++-------
 drivers/net/wireless/b43legacy/dma.c |   49 ++++++-----
 drivers/ssb/main.c                   |   76 +----------------
 include/linux/ssb/ssb.h              |  159 +---------------------------------
 5 files changed, 133 insertions(+), 360 deletions(-)
