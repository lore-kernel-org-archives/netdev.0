From: re.emese@gmail.com
Subject: [PATCH 0/3] constify various _ops structures for net-next-dave-git-a252e7
Date: Mon, 14 Dec 2009 00:59:39 +0100
Message-ID: <cover.1260707013.git.re.emese@gmail.com>
Cc: Emese Revfy <re.emese@gmail.com>, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756035AbZLNASb@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Emese Revfy <re.emese@gmail.com>

Hello everyone!

The following patch series attempts to constify several structures
that hold function pointers. This is only the initial batch, there
are other candidate structures, some of which can probably be
constified as well, I plan to submit them in the future.

The list of constified structures in this series:
e1000_mac_operations
e1000_phy_operations
e1000_nvm_operations

There are certain exceptions where a given instance of the structure
cannot be const, they are marked with a comment in the patch.

The patches compile fine with an allyesconfig kernel on i386 and x86_64.

Please let me know if any of these structures should not be constified
and any other issues you see with them.


Changelog:
----------
v1 -> v2
	- updated to net-next-dave-git-a252e7
	- extended comments with a reference to code that prevents constification

Thanks,
   Emese

 drivers/net/e1000e/82571.c    |   11 ++++++-----
 drivers/net/e1000e/e1000.h    |    6 +++---
 drivers/net/e1000e/es2lan.c   |    7 ++++---
 drivers/net/e1000e/hw.h       |   18 ++++++++++--------
 drivers/net/e1000e/ich8lan.c  |    6 +++---
 drivers/net/igb/e1000_82575.c |    6 +++---
 drivers/net/igb/e1000_hw.h    |    7 +++++--
 drivers/net/igbvf/vf.h        |    1 +
 8 files changed, 35 insertions(+), 27 deletions(-)
