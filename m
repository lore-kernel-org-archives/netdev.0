From: "Randy Macleod" <macleodr@nortel.com>
Subject: Re: [PATCH 6/6] Phonet: pipe end-point protocol documentation
Date: Tue, 14 Oct 2008 11:06:18 -0400
Message-ID: <48F4B56A.1070402@nortel.com>
References: <200810011312.17288.remi.denis-courmont@nokia.com> <1222855985-22859-6-git-send-email-remi.denis-courmont@nokia.com> <48EF9DE7.9040209@nortel.com> <20081011.123008.251386486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:46550 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbYJNPWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 11:22:47 -0400
In-Reply-To: <20081011.123008.251386486.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> It corrupted the patch, chopping up long lines and such.
> 
> There are directions in linux/Documentation/email-clients.txt on
> how to fix this.
> 
Fixed the line wrapping and RTFM.
Sending a test message to myself worked.

Here's the simple documentation patch, it's against:
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6

// Randy

diff --git a/Documentation/networking/phonet.txt b/Documentation/networking/phonet.txt
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



