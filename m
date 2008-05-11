From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] NET:  Replace deprecated __initcall with equivalent
 device_initcall.
Date: Sun, 11 May 2008 16:50:38 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0805111649300.21823@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:50592 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbYEKUul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2008 16:50:41 -0400
Received: from cpe001d60ad7267-cm001225dbafb6.cpe.net.cable.rogers.com ([99.236.100.208] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1JvIVE-0004AA-F9
	for netdev@vger.kernel.org; Sun, 11 May 2008 16:50:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index a637910..36fdf0f 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -772,4 +772,4 @@ static int __init am79c961_init(void)
 	return platform_driver_register(&am79c961_driver);
 }

-__initcall(am79c961_init);
+device_initcall(am79c961_init);

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
