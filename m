From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/9] treewide: convert vprintk uses to %pV
Date: Tue,  9 Nov 2010 16:35:14 -0800
Message-ID: <cover.1289348757.git.joe@perches.com>
Cc: dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Multiple secessive calls to printk can be interleaved.
Avoid this possible interleaving by using %pV

Joe Perches (9):
  drivers/gpu/drm/drm_stub.c: Use printf extension %pV
  drivers/isdn/mISDN: Use printf extension %pV
  drivers/net/wireless/ath/debug.c: Use printf extension %pV
  drivers/net/wireless/b43/main.c: Use printf extension %pV
  drivers/net/wireless/b43legacy/main.c: Use printf extension %pV
  fs/gfs2/glock.c: Use printf extension %pV
  fs/nilfs2/super.c: Use printf extension %pV
  fs/quota/dquot.c: Use printf extension %pV
  net/sunrpc/svc.c: Use printf extension %pV

 drivers/gpu/drm/drm_stub.c            |   14 +++++++--
 drivers/isdn/mISDN/layer1.c           |   10 +++++--
 drivers/isdn/mISDN/layer2.c           |   12 ++++++--
 drivers/isdn/mISDN/tei.c              |   23 +++++++++++----
 drivers/net/wireless/ath/debug.c      |    9 +++++-
 drivers/net/wireless/b43/main.c       |   48 ++++++++++++++++++++++++--------
 drivers/net/wireless/b43legacy/main.c |   47 ++++++++++++++++++++++++--------
 fs/gfs2/glock.c                       |    9 +++++-
 fs/nilfs2/super.c                     |   23 +++++++++++-----
 fs/quota/dquot.c                      |   12 +++++---
 net/sunrpc/svc.c                      |   12 +++++---
 11 files changed, 161 insertions(+), 58 deletions(-)

-- 
1.7.3.1.g432b3.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
