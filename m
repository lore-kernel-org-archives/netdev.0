From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 04 Apr 2009 17:17:13 -0700 (PDT)
Message-ID: <20090404.171713.82464159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754002AbZDEARY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 20:17:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) E1000 multicast packet loss fix from Jesse Brandeburg.

2) Two request_firmware() conversions (myri_sbus and bnx2)

3) B44 DMA fix from Michael Buesch.  This also could explain a bunch
   of bugs actually.

4) Use percpu_add() instead of by hand expansion, from Eric Dumazet.

5) vxge build fix from Alexander Beregalov.

6) virtio_net MAC setting fix from Alex Willaimson.

Please pull, thanks a lot!

The following changes since commit 6bb597507f9839b13498781e481f5458aea33620:
  Linus Torvalds (1):
        Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alex Williamson (1):
      virtio_net: Set the mac config only when VIRITO_NET_F_MAC

Alexander Beregalov (1):
      vxge: should include tcp.h

Eric Dumazet (1):
      socket: use percpu_add() while updating sockets_in_use

Jaswinder Singh Rajput (1):
      myri_sbus: use request_firmware

Jesse Brandeburg (1):
      e1000: fix loss of multicast packets

Michael Buesch (1):
      b44: Fix sizes passed to b44_sync_dma_desc_for_{device,cpu}()

Michael Chan (1):
      bnx2: Use request_firmware()

 drivers/net/Kconfig                       |    2 +-
 drivers/net/b44.c                         |    6 +-
 drivers/net/bnx2.c                        |  351 ++-
 drivers/net/bnx2.h                        |   71 +-
 drivers/net/bnx2_fw.h                     | 4378 +----------------------
 drivers/net/bnx2_fw2.h                    | 4547 ----------------------
 drivers/net/e1000/e1000_main.c            |   34 +-
 drivers/net/myri_code.h                   | 5006 -------------------------
 drivers/net/myri_sbus.c                   |   37 +-
 drivers/net/virtio_net.c                  |   10 +-
 drivers/net/vxge/vxge-main.c              |    1 +
 firmware/Makefile                         |    5 +
 firmware/WHENCE                           |   30 +
 firmware/bnx2/bnx2-mips-06-4.6.16.fw.ihex | 5805 ++++++++++++++++++++++++++++
 firmware/bnx2/bnx2-mips-09-4.6.17.fw.ihex | 5816 +++++++++++++++++++++++++++++
 firmware/bnx2/bnx2-rv2p-06-4.6.16.fw.ihex |  441 +++
 firmware/bnx2/bnx2-rv2p-09-4.6.15.fw.ihex |  490 +++
 firmware/myricom/lanai.bin.ihex           | 4771 +++++++++++++++++++++++
 net/socket.c                              |    6 +-
 19 files changed, 17671 insertions(+), 14136 deletions(-)
 delete mode 100644 drivers/net/bnx2_fw2.h
 delete mode 100644 drivers/net/myri_code.h
 create mode 100644 firmware/bnx2/bnx2-mips-06-4.6.16.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-mips-09-4.6.17.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-rv2p-06-4.6.16.fw.ihex
 create mode 100644 firmware/bnx2/bnx2-rv2p-09-4.6.15.fw.ihex
 create mode 100644 firmware/myricom/lanai.bin.ihex
