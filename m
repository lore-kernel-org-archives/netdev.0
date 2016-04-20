From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Subject: [PATCH 0/1] Revert "Prevent NUll pointer dereference with two PHYs"
Date: Wed, 20 Apr 2016 15:42:28 +0100
Message-ID: <1461163349-24696-1-git-send-email-andrew.goodbody@cambrionix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <grygorii.strashko@ti.com>,
	<tony@atomide.com>, <davem@davemloft.net>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Revert this patch as not only did it use an unitialised member of a struct
but there is also a pre-existing patch that does it better.

Andrew Goodbody (1):
  Revert "Prevent NUll pointer dereference with two PHYs on cpsw"

 drivers/net/ethernet/ti/cpsw.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

-- 
2.5.0
