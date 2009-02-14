From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 41/43] drivers/net/wireless/b43: fix warning: format not a
	string literal and no ...
Date: Sat, 14 Feb 2009 22:50:06 +0100
Message-ID: <20090214214956.24377.19315.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:51560 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514AbZBNVuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:50:10 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this compilation warning:
  drivers/net/wireless/b43/main.c: In function 'b43_print_fw_helptext':
  drivers/net/wireless/b43/main.c:1971: warning: format not a string literal and no format arguments
  drivers/net/wireless/b43/main.c:1973: warning: format not a string literal and no format arguments

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wireless/b43/main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index dbb8765..7116ab6 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1961,12 +1961,12 @@ static void b43_release_firmware(struct b43_wldev *dev)
 
 static void b43_print_fw_helptext(struct b43_wl *wl, bool error)
 {
-	const char *text;
+	const char text[] =
+		"You must go to " \
+		"http://wireless.kernel.org/en/users/Drivers/b43#devicefirmware " \
+		"and download the correct firmware for this driver version. " \
+		"Please carefully read all instructions on this website.\n";
 
-	text = "You must go to "
-	       "http://wireless.kernel.org/en/users/Drivers/b43#devicefirmware "
-	       "and download the correct firmware for this driver version. "
-	       "Please carefully read all instructions on this website.\n";
 	if (error)
 		b43err(wl, text);
 	else

