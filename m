From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 0/7] pci: Add VPD parsing support
Date: Thu, 25 Feb 2010 10:19:15 -0800
Message-ID: <1267121962-6077-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	andy@greyhouse.net, mcarlson@broadcom.com
To: jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2631 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933233Ab0BYSUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 13:20:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to help parse a device's VPD.  The bnx2 and tg3
network drivers are modified as an example on how to use the API.  I
believe the bnx2x driver will also use this API in the future.


