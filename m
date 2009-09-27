From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH 0/3] print UUID/GUIDs with %pU
Date: Sat, 26 Sep 2009 22:57:18 -0700
Message-ID: <cover.1254030722.git.joe@perches.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753143AbZI0F5Z@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Perhaps UUIDs are common enough to use a %p extension

Joe Perches (3):
  lib/vsprintf.c: Add %pU - ptr to a UUID/GUID
  treewide: use %pU to print UUID/GUIDs
  drivers/staging/hv/: use %pU to print UUID/GUIDs

 drivers/char/random.c                |   10 +--
 drivers/firmware/dmi_scan.c          |    5 +-
 drivers/md/md.c                      |   16 +----
 drivers/media/video/uvc/uvc_ctrl.c   |   69 +++++++++-----------
 drivers/media/video/uvc/uvc_driver.c |    7 +-
 drivers/media/video/uvc/uvcvideo.h   |   10 ---
 drivers/staging/hv/ChannelMgmt.c     |   22 +------
 drivers/staging/hv/vmbus_drv.c       |  116 ++++------------------------------
 fs/gfs2/sys.c                        |   16 +----
 fs/ubifs/debug.c                     |    9 +--
 fs/ubifs/super.c                     |    7 +--
 fs/xfs/xfs_log_recover.c             |   14 +---
 include/linux/efi.h                  |    6 +--
 lib/vsprintf.c                       |   58 +++++++++++++++++-
 14 files changed, 125 insertions(+), 240 deletions(-)
