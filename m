From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next (v2) 0/6] bnx2x: link patch series
Date: Thu, 21 Jun 2012 08:05:17 +0300
Message-ID: <1340255123-22371-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, joe@perches.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3198 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754439Ab2FUFHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 01:07:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series change bnx2x's link code. It contains both
semantic cleanup of the code as well as several patches that
add new support for optical modules - better 1G SFP support,
SFP+ Tx Fault support and implementation of the new ethtool API
for accessing the module's eeprom (on the bnx2x side).

Changes from Version 1:
  - Patch 2/6 - use usleep_range(small, small*2) instead of
		usleep_range(small, small).


Please consider applying this patch-series to 'net-next'.

Thanks,
Yuval Mintz
