From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/6] bnx2x: enhancement patch series
Date: Mon, 27 May 2013 17:08:25 +0300
Message-ID: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1743 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932587Ab3E0OIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 10:08:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains several enhancements, mainly the implementation of the
PCI shutdown callback which improves the bnx2x support in un-orderly shutdowns,
and following that a change in the driver's power scheme which lowers PCI power
state only when driver is removed (and as a result enable eeprom access on
unloaded interfaces).

Please consider applying these patches to `net-next'.

Thanks,
Yuval Mintz
