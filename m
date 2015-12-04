From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next 0/3] bnx2x: fewer error messages, simplification
Date: Fri,  4 Dec 2015 17:22:33 +0100
Message-ID: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45242 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534AbbLDQWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 11:22:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This removes one redundant error message in bnx2x and changes another one to
WARN_ONCE. The third patch is a small simplification in ethtool stats.

Michal Schmidt (3):
  bnx2x: drop redundant error message about allocation failure
  bnx2x: change FW GRO error message to WARN_ONCE
  bnx2x: simplify distinction between port and func stats

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   6 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 117 ++++++++++-----------
 2 files changed, 58 insertions(+), 65 deletions(-)

-- 
2.5.0
