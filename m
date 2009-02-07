From: jamal <hadi@cyberus.ca>
Subject: [PATCH] iproute2 :  ipt - free local opts
Date: Sat, 07 Feb 2009 08:59:53 -0500
Message-ID: <1234015193.4441.8.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-gOi8gt2tzQ9zGRlhLFWm"
Cc: netdev@vger.kernel.org, Denys Fedoryschenko <denys@visp.net.lb>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:58130 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbZBGOBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 09:01:44 -0500
Received: by ewy14 with SMTP id 14so1825855ewy.13
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2009 06:01:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gOi8gt2tzQ9zGRlhLFWm
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


>From Denys Fedoryschenko <denys@visp.net.lb>
This was left out in the last release. It is a bug fix for when
batch files are used.

cheers,
jamal

--=-gOi8gt2tzQ9zGRlhLFWm
Content-Disposition: attachment; filename=fixmipt-feb7
Content-Type: text/plain; name=fixmipt-feb7; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit eb3c0ea70d7fd47c8a132f2e7a7dfce734c2394b
Author: Denys Fedoryschenko <denys@visp.net.lb>
Date:   Sat Feb 7 08:49:32 2009 -0500

    This change was forgotten by Stephen in the last release
    
    Signed-off-by: Denys Fedoryschenko <denys@visp.net.lb>
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/tc/m_ipt.c b/tc/m_ipt.c
index f5b7b3c..5b98428 100644
--- a/tc/m_ipt.c
+++ b/tc/m_ipt.c
@@ -162,10 +162,10 @@ int string_to_number(const char *s, unsigned int min, unsigned int max,
 	return result;
 }
 
-static void free_opts(struct option *opts)
+static void free_opts(struct option *local_opts)
 {
-	if (opts != original_opts) {
-		free(opts);
+	if (local_opts != original_opts) {
+		free(local_opts);
 		opts = original_opts;
 		global_option_offset = 0;
 	}


--=-gOi8gt2tzQ9zGRlhLFWm--

