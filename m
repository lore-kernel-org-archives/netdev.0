From: "Reeuwijk, C. van" <c.van.reeuwijk@vu.nl>
Subject: [PATCH] iproute2: add a missing return statement to do_help()
Date: Thu, 31 Jan 2013 16:03:20 +0000
Message-ID: <36C368FA-A2DE-442D-9FF3-E6E904533535@cs.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.vu.nl ([130.37.164.18]:7155 "EHLO mailin.vu.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab3AaQIt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 11:08:49 -0500
Content-Language: en-US
Content-ID: <537BC71CE65F2148BACD16920705D878@ad.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees van Reeuwijk <reeuwijk@few.vu.nl>

Since do_help() has to return an int to fit in the table of commands, it should actually return an int. This patch lets it do so.

Signed-off-by: Kees van Reeuwijk <reeuwijk@few.vu.nl>

---

 {upstream/master:ip => master:ip}/ip.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/upstream/master:ip/ip.c b/master:ip/ip.c
index 632d271..c3ff627 100644
--- a/upstream/master:ip/ip.c
+++ b/master:ip/ip.c
@@ -57,6 +57,7 @@ static void usage(void)
 static int do_help(int argc, char **argv)
 {
 	usage();
+        return 0;
 }
 
 static const struct cmd {

-- 
Dr. ir. Kees van Reeuwijk, Vrije Universiteit Amsterdam
