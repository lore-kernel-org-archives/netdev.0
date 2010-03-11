From: Jan Engelhardt <jengelh@medozas.de>
Subject: [net-next] IFLA_STATS64, tcp cong modules
Date: Thu, 11 Mar 2010 20:57:26 +0100
Message-ID: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:56837 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752876Ab0CKT5f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 14:57:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi!


Here are three simple patches for net-next aka to-be-2.6.35.

The following changes since commit 3a5b27bf6f29574d667230c7e76e4b83fe3014e0:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://gitorious.org/linux-omap-dss2/linux

are available in the git repository at:

  git://dev.medozas.de/linux net

Jan Engelhardt (3):
      net: tcp: make hybla selectable as default congestion module
      net: tcp: make veno selectable as default congestion module
      net: core: add IFLA_STATS64 support

 include/linux/if_link.h |   33 +++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c    |   42 +++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/Kconfig        |    8 ++++++++
 3 files changed, 82 insertions(+), 1 deletions(-)
