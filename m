From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/4] Mellaox 40G driver fixes for 4.6-rc
Date: Wed, 20 Apr 2016 16:01:14 +0300
Message-ID: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51067 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753363AbcDTNBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 09:01:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

With the fix for ARM bug being under the works, these are 
few other fixes for mlx4 we have ready to go.

Eran addressed the problematic/wrong reporting of dropped packets, Daniel 
fixed some matters related to PPC EEH's and Jenny's patch makes sure
VFs can't change the port's pause settings.

Or.

Daniel Jurgens (2):
  net/mlx4_core: Implement pci_resume callback
  net/mlx4_core: Avoid repeated calls to pci enable/disable

Eran Ben Elisha (1):
  net/mlx4_en: Split SW RX dropped counter per RX ring

Eugenia Emantayev (1):
  net/mlx4_core: Don't allow to VF change global pause settings

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  5 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |  5 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c       | 76 ++++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h       |  2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  1 +
 drivers/net/ethernet/mellanox/mlx4/port.c       | 13 +++++
 include/linux/mlx4/device.h                     |  7 +++
 8 files changed, 89 insertions(+), 22 deletions(-)

-- 
2.3.7
