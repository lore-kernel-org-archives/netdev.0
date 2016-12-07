From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2016-12-07
Date: Wed,  7 Dec 2016 10:50:39 +0100
Message-ID: <20161207095040.5003-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:58469 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932094AbcLGJup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:50:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Andrey Konovalov triggered a warning in the CAN RAW layer, which is fixed by a
patch by me.

regards,
Marc

---

The following changes since commit bc3913a5378cd0ddefd1dfec6917cc12eb23a946:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc (2016-12-06 09:24:11 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.9-20161207

for you to fetch changes up to 332b05ca7a438f857c61a3c21a88489a21532364:

  can: raw: raw_setsockopt: limit number of can_filter that can be set (2016-12-07 10:45:57 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.9-20161207

----------------------------------------------------------------
Marc Kleine-Budde (1):
      can: raw: raw_setsockopt: limit number of can_filter that can be set

 include/uapi/linux/can.h | 1 +
 net/can/raw.c            | 3 +++
 2 files changed, 4 insertions(+)
