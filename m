From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Subject: [PATCH v2 0/1] Revert "Prevent NUll pointer dereference with two PHYs"
Date: Wed, 20 Apr 2016 16:14:50 +0100
Message-ID: <1461165291-25043-1-git-send-email-andrew.goodbody@cambrionix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <grygorii.strashko@ti.com>,
	<tony@atomide.com>, <davem@davemloft.net>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta14.messagelabs.com ([193.109.254.120]:9786 "EHLO
	mail1.bemta14.messagelabs.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751002AbcDTPPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 11:15:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Revert this patch as not only did it use an unitialised member of a struct
but there is also a pre-existing patch that does it better.

V2 add signoff

Andrew Goodbody (1):
  Revert "Prevent NUll pointer dereference with two PHYs on cpsw"

 drivers/net/ethernet/ti/cpsw.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

-- 
2.5.0
