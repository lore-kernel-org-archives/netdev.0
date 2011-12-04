From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCHv2 net-next 0/4] caif: CAIF for CDC NCM USB
Date: Sun,  4 Dec 2011 11:10:46 +0100
Message-ID: <1322993450-8802-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@stericsson.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57725 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab1LDKLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 05:11:08 -0500
Received: by eeaq14 with SMTP id q14so1458926eea.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 02:11:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's a new version of CAIF NCM patches. Patch 1-2 make sense to apply
even without patch 3-4. I reworked locking in patch-3 and added patch-4
based on review comments from Eric.

Thanks,
Sjur Br=C3=A6ndeland

Sjur Br=C3=A6ndeland (4):
  if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
  caif: Add support for CAIF over CDC NCM USB interface
  caif: Add support for flow-control on device's tx-queue
  caif: Stash away hijacked skb destructor and call it later

 include/linux/if_ether.h  |    1 +
 include/net/caif/cfusbl.h |   13 +++
 net/caif/Kconfig          |   11 +++
 net/caif/Makefile         |    4 +-
 net/caif/caif_dev.c       |  124 ++++++++++++++++++++++++++++-
 net/caif/cfusbl.c         |  199 +++++++++++++++++++++++++++++++++++++=
++++++++
 6 files changed, 350 insertions(+), 2 deletions(-)
 create mode 100644 include/net/caif/cfusbl.h
 create mode 100644 net/caif/cfusbl.c
