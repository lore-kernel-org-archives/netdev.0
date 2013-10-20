From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net v2 0/9] bnx2x: Bug fixes patch series
Date: Sun, 20 Oct 2013 16:51:25 +0200
Message-ID: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2638 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750986Ab3JTOvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 10:51:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains fixes for various flows - several SR-IOV issues
are fixed, ethtool callbacks (coalescing and register dump) are corrected,
null pointer dereference on error flows is prevented, etc.

Changes from V1
---------------
 - Patch 2  "bnx2x: Prevent an illegal pointer dereference during panic"
   is revised, with improved handling of edge cases.


Please consider applying this series to 'net'.

Thanks,
Yuval Mintz
