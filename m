From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH 0/1] net/hyperv: Add flow control based on hi/low watermark
Date: Tue, 27 Mar 2012 15:23:06 -0700
Message-ID: <1332886987-11613-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is targeting 'net-next' tree (when re-opened).


Haiyang Zhang (1):
  net/hyperv: Add flow control based on hi/low watermark

 drivers/hv/ring_buffer.c        |   31 -----------------------------
 drivers/net/hyperv/netvsc.c     |   41 +++++++++++++++++++++++++++++++++++---
 drivers/net/hyperv/netvsc_drv.c |    6 ++++-
 include/linux/hyperv.h          |   29 +++++++++++++++++++++++++++
 4 files changed, 71 insertions(+), 36 deletions(-)

-- 
1.7.4.1
