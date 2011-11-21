From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH net-next 0/5] atm: cleanups and MSK_PEEK for atm sockets
Date: Mon, 21 Nov 2011 21:25:53 +0100
Message-ID: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:56403 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850Ab1KUU0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:26:16 -0500
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019764592.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 21:26:10 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

    This series does some cleanup and introduces MSG_PEEK support for ATM
sockets.

Jorge Boncompte [DTI2] (5):
  atm: br2684: Do not move counters backwards
  atm: clip: Don't move counters backwards
  atm: clip: move clip_devs check to clip_push
  atm: Introduce vcc_process_recv_queue
  atm: Allow MSG_PEEK for atm sockets

 net/atm/br2684.c  |   27 +++++----------------------
 net/atm/clip.c    |   34 +++++++++-------------------------
 net/atm/common.c  |   34 +++++++++++++++++++++++++++++++---
 net/atm/common.h  |    1 +
 net/atm/pppoatm.c |    4 ++++
 5 files changed, 50 insertions(+), 50 deletions(-)

-- 
1.7.7.1
