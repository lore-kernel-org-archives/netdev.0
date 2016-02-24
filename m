From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/6] qed*: Driver updates
Date: Wed, 24 Feb 2016 16:52:44 +0200
Message-ID: <1456325570-1514-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:12784 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751166AbcBXOxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 09:53:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usually I try to provide a sensible description of the patch set even if
it lacks a general 'motif', but this simply contains several small,
unrelated and self-explenatory tweaks and additions.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Yuval Mintz (6):
  qede: Change pci DID for 10g device
  qede: Linearize SKBs when needed
  qede: Don't report link change needlessly
  qed: add MODULE_FIRMWARE()
  qed: Prevent probe on previous error
  qed, qede: rebrand module description

 drivers/net/ethernet/qlogic/qed/qed_main.c   | 19 +++++++--
 drivers/net/ethernet/qlogic/qede/qede_main.c | 62 +++++++++++++++++++++-------
 2 files changed, 63 insertions(+), 18 deletions(-)
-- 
1.8.3.1
