From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/4] qlge: Fixes and clean up for qlge.
Date: Wed, 11 Nov 2009 14:54:02 -0800
Message-ID: <1257980046-2420-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:24232 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759468AbZKKXAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 18:00:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Two small fixes, one cleanup and a driver version change for qlge.

1) Remove frame route change in qlge_suspend().  This operation is now
done by the firmware.

2) Add asic reset to force known state at open().

3) Change module parameter to match qlge_xxx convention.

4) Change driver version.


