From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/4] tulip: logging cleanups
Date: Fri,  6 May 2011 19:08:41 -0700
Message-ID: <cover.1304733889.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (4):
  tulip: xircom_cb: Convert #ifdef DEBUG blocks and enter/leave uses
  tulip: Convert printks to netdev_<level>
  tulip: Convert uses of KERN_DEBUG
  tulip: Use pr_<level> where appropriate

 drivers/net/tulip/21142.c       |   14 +-
 drivers/net/tulip/Makefile      |    2 +
 drivers/net/tulip/de2104x.c     |  174 +++++++++++-------------
 drivers/net/tulip/dmfe.c        |    9 +-
 drivers/net/tulip/eeprom.c      |    4 +-
 drivers/net/tulip/interrupt.c   |   48 ++++----
 drivers/net/tulip/media.c       |   49 ++++----
 drivers/net/tulip/pnic.c        |   22 ++--
 drivers/net/tulip/pnic2.c       |   16 +-
 drivers/net/tulip/timer.c       |   47 +++----
 drivers/net/tulip/tulip.h       |    8 +-
 drivers/net/tulip/tulip_core.c  |   50 +++----
 drivers/net/tulip/uli526x.c     |   65 +++------
 drivers/net/tulip/winbond-840.c |   81 ++++++------
 drivers/net/tulip/xircom_cb.c   |  286 ++++++++++++++++++++-------------------
 15 files changed, 417 insertions(+), 458 deletions(-)

-- 
1.7.5.rc3.dirty
