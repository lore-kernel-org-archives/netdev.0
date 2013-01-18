From: Benjamin Kerensa <bkerensa@ubuntu.com>
Subject: small iputils patch to remove excessive punctuation
Date: Thu, 17 Jan 2013 23:22:31 -0800
Message-ID: <CAGOdq5mESsfh063GnOS=kUio6M_FfNJsGfbZCBUS39aoD78m_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:54331 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab3ARHXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 02:23:12 -0500
Received: by mail-oa0-f44.google.com with SMTP id n5so3562409oag.17
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 23:23:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a quick iputils patch to remove unneeded punctuation from ping
flood warning in ping_common.c




Signed-off-by: Benjamin Kerensa <bkerensa@ubuntu.com>
---
 ping_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ping_common.c b/ping_common.c
index 7f82851..261aafc 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -608,7 +608,7 @@ void setup(int icmp_sock)
         interval = 0;

     if (uid && interval < MINUSERINTERVAL) {
-        fprintf(stderr, "ping: cannot flood; minimal interval,
allowed for user, is %dms\n", MINUSERINTERVAL);
+        fprintf(stderr, "ping: cannot flood; minimal interval allowed
for user is %dms\n", MINUSERINTERVAL);
         exit(2);
     }

--
1.8.0
