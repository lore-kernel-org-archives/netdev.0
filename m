From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: better document max_addresses parameter
Date: Mon, 22 Feb 2010 17:27:21 -0500
Message-ID: <4B8304C9.1030800@hp.com>
References: <bug-15342-10286@http.bugzilla.kernel.org/> <20100222130858.3c186888.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: nedyalkor@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:15170 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687Ab0BVW1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 17:27:25 -0500
In-Reply-To: <20100222130858.3c186888.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
>> >From ip-sysctl.txt file in kernel documentation I can see following description
>> for max_addresses:
>> max_addresses - INTEGER
>>         Number of maximum addresses per interface.  0 disables limitation.
>>         It is recommended not set too large value (or 0) because it would
>>         be too easy way to crash kernel to allow to create too much of
>>         autoconfigured addresses.
           ^^^^^^^^^^^^^^

>> If this parameter applies only for auto-configured IP addressed, please state
>> it more clearly in docs or rename the parameter to show that it refers to
>> auto-configuration.

It did mention autoconfigured in the text, but the below makes it more obvious.


More clearly document IPv6 max_addresses parameter.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 2571a62..8b72c88 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1126,10 +1126,10 @@ regen_max_retry - INTEGER
 	Default: 5
 
 max_addresses - INTEGER
-	Number of maximum addresses per interface.  0 disables limitation.
-	It is recommended not set too large value (or 0) because it would
-	be too easy way to crash kernel to allow to create too much of
-	autoconfigured addresses.
+	Maximum number of autoconfigured addresses per interface.  Setting
+	to zero disables the limitation.  It is not recommended to set this
+	value too large (or to zero) because it would be an easy way to
+	crash the kernel by allowing too many addresses to be created.
 	Default: 16
 
 disable_ipv6 - BOOLEAN
