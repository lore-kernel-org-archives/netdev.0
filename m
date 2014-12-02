From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net-next 0/2] r8169:change hardware setting
Date: Tue, 2 Dec 2014 16:48:29 +0800
Message-ID: <1417510111-3568-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series contains two hardware setting modification to prevent
hardware become abnormal.

Chunhao Lin (2):
  r8169:prevent enable hardware tx/rx too early
  r8169:disable rtl8168ep cmac engine

 drivers/net/ethernet/realtek/r8169.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

-- 
1.9.1
