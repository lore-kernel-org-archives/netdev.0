From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/13] bnx2x: patch series
Date: Mon, 11 Mar 2013 17:17:40 +0200
Message-ID: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3896 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116Ab3CKQZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 12:25:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains several changes:

 1. SR-IOV related patches - allow setting and getting the number of VFs
    via sysfs, configuring and querying VFs via iproute2 callbacks and
    properly implement for VFs only the ethtool ops which they can safely
    perform.

 2. Advance the FW version used by the driver. This allows 57840 boards to
    use FCoE, as well as fixing various issues.

 3. Several small link enhancements.

 4. Several fixes of rare corner-cases.

Please consider applying this patch-series to 'net-next'.

Thanks,
Yuval Mintz
