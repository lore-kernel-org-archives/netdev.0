From: Ralf Baechle <ralf@linux-mips.org>
Subject: NET: SB1250: Initialize .owner
Date: Tue, 6 Jul 2010 16:18:11 +0100
Message-ID: <20100706151811.GA4829@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org,
	"Maciej W. Rozycki" <macro@linux-mips.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:60436 "EHLO h5.dl5rb.org.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106Ab0GFPSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jul 2010 11:18:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/sb1250-mac.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 1f3acc3..79eee30 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2671,6 +2671,7 @@ static struct platform_driver sbmac_driver = {
 	.remove = __exit_p(sbmac_remove),
 	.driver = {
 		.name = sbmac_string,
+		.owner  = THIS_MODULE,
 	},
 };
 
