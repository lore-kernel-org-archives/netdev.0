From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [net-next-2.6 00/08] r8169 driver updates
Date: Mon, 3 Jan 2011 00:35:31 +0100
Message-ID: <20110102233531.GA5780@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <benh@debian.org>,
	David Woodhouse <dwmw2@infradead.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51672 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab1ABXfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 18:35:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series includes:
- Hayes'firmware removal. The firmware is already included in linux-firmware.
- my sauce to diminish the gap between the in-kernel r8169 driver
  and Realtek's one(s).

I have not noticed any regression while doing some basic testing with the
chipsets below (Realtek's own label are included between parenthesis).

- RTL8169sc/8110sc XID 98000000 (RTL8110SC)
- RTL8102e         XID 14c00000 (RTL8103E-GR)
- RTL8102e         XID 04a00000 (RTL8102E-VB-GR)
- RTL8101e         XID 00a00000 (RTL8105E-VG)
- RTL8168d/8111d   XID 083000c0 (RTL8111D-VB-GR)
- RTL8168d/8111d   XID 081000c0 (RTL8168D-GR)

The series is available as
git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-davem

Distance from 'net-next' (40cd201e37073b3e2281cf2c73fcf5674f22267f)
-------------------------------------------------------------------

c853fd7221941839af1799d8f47daa2ae8cf65ef
ffbbf19c870a92b841a224db14cda64ad81598cf
82636521a5a60abc6ccadbfed1b2424d5be6bb49
ee37a075949e32bb336a54c93abc7d4771898264
a19878e168201c09f6f631bbef40b67a0e374078
dfbd1ebbd95cdc63f31b59d62bf9e652657d7241
d7b9a3f0f524085cc8fee0388d369cfb43e588c7
60631b47144e6f5d0003eaf66d376046d592b78f

Diffstat
--------

 drivers/net/r8169.c | 1632 +++++++++++++++++++++++++--------------------------
 1 files changed, 784 insertions(+), 848 deletions(-)

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
