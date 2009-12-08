From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/20] net/atm: Cleanups
Date: Mon,  7 Dec 2009 21:56:56 -0800
Message-ID: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1036 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932381AbZLHF5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduced checkpatch complaints, added a couple of cleanup functions
to reduce indentation levels

Joe Perches (20):
  net/atm: Convert printk to pr_<level>
  net/atm/addr.c: checkpatch cleanups
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

 net/atm/addr.c        |    2 +-
 net/atm/atm_misc.c    |   40 ++--
 net/atm/atm_sysfs.c   |   27 ++-
 net/atm/br2684.c      |   90 ++++----
 net/atm/clip.c        |   86 ++++----
 net/atm/common.c      |  386 ++++++++++++++++---------------
 net/atm/ioctl.c       |  196 ++++++++--------
 net/atm/lec.c         |  601 +++++++++++++++++++++++--------------------------
 net/atm/mpc.c         |  443 +++++++++++++++++++++----------------
 net/atm/mpoa_caches.c |  154 +++++++------
 net/atm/mpoa_proc.c   |   65 +++---
 net/atm/pppoatm.c     |   28 ++-
 net/atm/proc.c        |   81 ++++---
 net/atm/pvc.c         |   43 ++--
 net/atm/raw.c         |   26 +--
 net/atm/resources.c   |  402 ++++++++++++++++-----------------
 net/atm/signaling.c   |  219 +++++++++---------
 net/atm/svc.c         |  258 +++++++++++-----------
 18 files changed, 1589 insertions(+), 1558 deletions(-)

