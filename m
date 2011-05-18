From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 0/2] bna: Add Debugfs & Generic Netlink Interfaces to BNA Driver
Date: Tue, 17 May 2011 21:56:59 -0700
Message-ID: <1305694621-28023-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36676 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069Ab1ERE5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 00:57:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds debugfs and generic netlink interfaces to BNA driver for
debugging and managing the Brocade adapter.

Rasesh Mody (2):
  bna: Add Debugfs Interface
  bna: Add Generic Netlink Interface

 drivers/net/bna/Makefile       |    3 +-
 drivers/net/bna/bfa_defs.h     |   18 ++
 drivers/net/bna/bfa_ioc.c      |  113 +++++++++++++-
 drivers/net/bna/bfa_ioc.h      |    7 +
 drivers/net/bna/bfi.h          |    2 +
 drivers/net/bna/bna_ctrl.c     |    5 +-
 drivers/net/bna/bnad.c         |   48 +++++-
 drivers/net/bna/bnad.h         |   16 ++-
 drivers/net/bna/bnad_debugfs.c |  302 +++++++++++++++++++++++++++++++++++
 drivers/net/bna/bnad_genl.c    |  345 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/bna/bnad_genl.h    |   87 ++++++++++
 11 files changed, 931 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/bna/bnad_debugfs.c
 create mode 100644 drivers/net/bna/bnad_genl.c
 create mode 100644 drivers/net/bna/bnad_genl.h

