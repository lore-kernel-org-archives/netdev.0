From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 0/4] qed*: driver updates
Date: Fri, 22 Apr 2016 08:41:00 +0300
Message-ID: <1461303664-15961-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:63952 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751465AbcDVFlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 01:41:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Was previous termed 'eeprom access et al.', but seemed a bit
inappropriate given we've dropped the eeprom patch for now.
Still waiting for some inputs on that one, BTW]

This patch series contains some ethtool-related enhancements.

Dave,

Please consider applying this to `net-next'.

Thanks [and happy Passover],
Yuval

Changes
-------
 - V1:  Dropped eeprom access until it's decided how to address that.
        Semantically changed patch #2 [Feedback from Sergei Shtylyov].

Sudarsana Reddy Kalluru (1):
  qed: add support for link pause configuration.

Yuval Mintz (3):
  qed*: Align statistics names
  qede: Add support for ethtool private flags
  qed*: Conditions for changing link

 drivers/net/ethernet/qlogic/qed/qed_l2.c        | 20 ++++-----
 drivers/net/ethernet/qlogic/qed/qed_main.c      | 20 +++++++++
 drivers/net/ethernet/qlogic/qede/qede.h         | 20 ++++-----
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 57 +++++++++++++++++++------
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 29 ++++++++-----
 include/linux/qed/qed_if.h                      | 30 ++++++++-----
 6 files changed, 122 insertions(+), 54 deletions(-)

-- 
1.9.3
