From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [net-next-2.6 #2 00/08] r8169 driver updates
Date: Tue, 4 Jan 2011 02:07:16 +0100
Message-ID: <20110104010716.GA5957@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <benh@debian.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42046 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab1ADBHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 20:07:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series adds on top of the previous one :
- missing TxPacketMax and FW_LOADER (Ben Hutchings)
- wrong OCPDR_GPHY_REG offset and mask.
  Hayes, are you ok with this one ?

The RTL_GIGA_MAC_VER_27 changes suggested by Hayes at the end of the
previous series are not included yet (feedback anyone ?).

The previous series included :
- Hayes'firmware removal. The firmware is already included in linux-firmware.
- my sauce to diminish the gap between the in-kernel r8169 driver
  and Realtek's one(s).

The series is available as:
git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-davem

Distance from 'net-next' (68763c890eb2a60f9b50a061502f94e0cf20fdfe)
-------------------------------------------------------------------

d476010e89248593e250bd8da2c75f3ddf8a33d2
0874279a535c97d97797f05dd2e42b7c0878479e
6845fe716c5a4af123ac6db1a88a62363850107c
78aa4513d0f1204419a3a9a444b97e21eaaa3e12
45a6801e5443d8e35529cbf5b560632c1dbe5675
dd108743c3c36bd7905c6e0882c1aa42fc0d7e51
9ac42f66ba7fdec680c846ac83d124f4dca68ef9
a016536f2f5304c199129822c6898bd95d9b72b5

Diffstat
--------

 drivers/net/Kconfig |    1 +
 drivers/net/r8169.c | 1632 +++++++++++++++++++++++++--------------------------
 2 files changed, 785 insertions(+), 848 deletions(-)

Shortlog
--------

Francois Romieu (7):
      r8169: identify different registers.
      r8169: use device dependent methods to access the MII registers.
      r8169: 8168DP specific MII registers access methods.
      r8169: phy power ops
      r8169: magic.
      r8169: rtl_csi_access_enable rename.
      r8169: more 8168dp support.

Hayes Wang (1):
      r8169: remove the firmware of RTL8111D.

-- 
Ueimor
