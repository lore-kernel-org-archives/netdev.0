From: Gregory Haskins <ghaskins@novell.com>
Subject: [PATCH 0/2] net: vbus-enet fixes
Date: Fri, 16 Oct 2009 09:36:13 -0400
Message-ID: <20091016133411.13423.36106.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759393AbZJPNhH@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following apply to the linux-next branch for AlacrityVM:

git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git

The series fixes a few problems discovered via community feedback and
lockdep.  Please see the patch headers for more details.

Kind Regards,
-Greg

---

Gregory Haskins (2):
      venet: fix locking issue with dev_kfree_skb()
      net: fix vbus-enet Kconfig dependencies


 drivers/net/Kconfig     |    2 +
 drivers/net/vbus-enet.c |   71 +++++++++++++++++++++++------------------------
 2 files changed, 36 insertions(+), 37 deletions(-)

-- 
Signature
