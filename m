From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 0/3] bnx2x: Link flap avoidance added
Date: Thu, 13 Sep 2012 15:56:18 +0300
Message-ID: <1347540981-16198-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3284 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224Ab2IMNVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 09:21:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

In various flows in the bnx2x driver, the link is toggled unnecessarily -
In such flows, if the link is already up it would be pulled down than
raised up again, even if no change in the link was requested by the
user.

This patch series tries to eliminate this problem, or at least to greatly
reduce the number of cases that would actually cause such a scenario to
happen.

Please consider applying this patch series to 'net-next'.

Thanks,
Yuval
