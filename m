From: Joe Perches <joe@perches.com>
Subject: [net-next PATCH 00/21] net/atm neatening cleanups
Date: Tue, 26 Jan 2010 13:39:59 -0800
Message-ID: <cover.1264541547.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1468 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab0AZVkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 16:40:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous cleanups to net/atm

Joe Perches (21):
  net/atm: Convert printk to pr_<level>
  net/atm/addr.c: Convert include <asm to include <linux
  net/atm/atm_misc.c: checkpatch cleanups
  net/atm/atm_sysfs.c: checkpatch cleanups
  net/atm/br2684.c: checkpatch cleanups
  net/atm/clip.c: checkpatch cleanups
  net/atm/common.c: checkpatch cleanups
  net/atm/ioctl.c: checkpatch cleanups
  net/atm/lec.c: checkpatch cleanups
  net/atm/mpc.c: checkpatch cleanups
  net/atm/mpoa_caches.c: checkpatch cleanups
  net/atm/mpoa_proc.c: checkpatch cleanups
  net/atm/pppoatm.c: checkpatch cleanups
  net/atm/proc.c: checkpatch cleanups
  net/atm/pvc.c: checkpatch cleanups
  net/atm/raw.c: checkpatch cleanups
  net/atm/resources.c: checkpatch cleanups
  net/atm/signaling.c: checkpatch cleanups
  net/atm/svc.c: checkpatch cleanups
  net/atm/lec.c: Add __lec_arp_check_expire and other cleanups
  net/atm: Cleanup dprint/ddprintk #defines and uses

 net/atm/addr.c        |    2 +-
 net/atm/atm_misc.c    |   40 ++--
 net/atm/atm_sysfs.c   |   27 ++-
 net/atm/br2684.c      |   90 ++++----
 net/atm/clip.c        |   86 ++++----
 net/atm/common.c      |  386 ++++++++++++++++---------------
 net/atm/ioctl.c       |  196 ++++++++--------
 net/atm/lec.c         |  599 +++++++++++++++++++++++--------------------------
 net/atm/mpc.c         |  540 +++++++++++++++++++++++++--------------------
 net/atm/mpoa_caches.c |  190 +++++++++-------
 net/atm/mpoa_proc.c   |   89 ++++----
 net/atm/pppoatm.c     |   28 ++-
 net/atm/proc.c        |   81 ++++---
 net/atm/pvc.c         |   43 ++--
 net/atm/raw.c         |   26 +--
 net/atm/resources.c   |  402 ++++++++++++++++-----------------
 net/atm/signaling.c   |  219 +++++++++---------
 net/atm/svc.c         |  258 +++++++++++-----------
 18 files changed, 1675 insertions(+), 1627 deletions(-)

