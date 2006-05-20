From: Chris Wedgwood <cw@f00f.org>
Subject: [PATCH] MPPE probably doesn't need to be EXPERIMENTAL
Date: Fri, 19 May 2006 19:53:08 -0700
Message-ID: <20060520025308.GC9486@taniwha.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.sbc.mail.mud.yahoo.com ([68.142.198.208]:3431 "HELO
	smtp109.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S964829AbWETCxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 22:53:11 -0400
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A lot of people use MPPE and I'm not aware of too many complaints with
this.  Remove it's EXPERIMENTAL status.


Signed-off-by: Chris Wedgwood <cw@f00f.org>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index aa633fa..2c56a95 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2579,8 +2579,8 @@ config PPP_BSDCOMP
 	  modules once you have said "make modules". If unsure, say N.
 
 config PPP_MPPE
-       tristate "PPP MPPE compression (encryption) (EXPERIMENTAL)"
-       depends on PPP && EXPERIMENTAL
+       tristate "PPP MPPE compression (encryption)"
+       depends on PPP
        select CRYPTO
        select CRYPTO_SHA1
        select CRYPTO_ARC4
