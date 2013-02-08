From: Kees van Reeuwijk <kees.van.reeuwijk@gmail.com>
Subject: [PATCH v2 1/5] iproute2: add a missing return statement
Date: Fri, 08 Feb 2013 14:32:36 +0100
Message-ID: <E1U3o4C-0000bv-O3@babylon.few.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:58588 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946070Ab3BHNel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 08:34:41 -0500
Received: by mail-wi0-f173.google.com with SMTP id hq4so845913wib.12
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 05:34:39 -0800 (PST)
Received: from reeuwijk by babylon.few.vu.nl with local (Exim 4.72)
	(envelope-from <reeuwijk@few.vu.nl>)
	id 1U3o4C-0000bv-O3
	for netdev@vger.kernel.org; Fri, 08 Feb 2013 14:32:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees van Reeuwijk <reeuwijk@few.vu.nl>

Since do_help() has to return an int to fit in the table of commands,
it should actually return an int. This patch lets it do so.

Signed-off-by: Kees van Reeuwijk <reeuwijk@few.vu.nl>

---


 ip.c             |    1 +
diff --git a/ip/ip.c b/ip/ip.c
index 632d271..c3ff627 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -57,6 +57,7 @@ static void usage(void)
 static int do_help(int argc, char **argv)
 {
 	usage();
+        return 0;
 }
 
 static const struct cmd {
