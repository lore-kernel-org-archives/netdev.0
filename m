From: "Randy Macleod" <macleodr@nortel.com>
Subject: Re: [PATCH 6/6] Phonet: pipe end-point protocol documentation
Date: Fri, 10 Oct 2008 14:24:39 -0400
Message-ID: <48EF9DE7.9040209@nortel.com>
References: <200810011312.17288.remi.denis-courmont@nokia.com> <1222855985-22859-6-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:44526 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762040AbYJJSYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 14:24:43 -0400
In-Reply-To: <1222855985-22859-6-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor documentation fix.
Is this patch formatted as desired (first patch!)?
I'm using Thunderbird.

// Randy



Signed-off-by: Randy MacLeod <macleodr@nortel.com>

git diff Documentation/networking/phonet.txt
diff --git a/Documentation/networking/phonet.txt
b/Documentation/networking/phonet.txt
index 0e6e592..6a07e45 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -146,8 +146,8 @@ WARNING:
 When polling a connected pipe socket for writability, there is an
 intrinsic race condition whereby writability might be lost between the
 polling and the writing system calls. In this case, the socket will
-block until write because possible again, unless non-blocking mode
-becomes enabled.
+block until write becomes possible again, unless non-blocking mode
+is enabled.


 The pipe protocol provides two socket options at the SOL_PNPIPE level:



