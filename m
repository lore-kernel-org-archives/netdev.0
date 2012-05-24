From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/wanrouter: Deprecate and schedule for removal
Date: Thu, 24 May 2012 10:13:30 -0700
Message-ID: <1337879610.5070.17.camel@joe2Laptop>
References: <1337708034.3432.0.camel@joe2Laptop>
	 <4FBE3CFC.6070103@computer.org>
	 <20120524091310.1c01577e@nehalam.linuxnetplumber.net>
	 <1337876577.5070.7.camel@joe2Laptop> <4FBE62AB.6000900@candelatech.com>
	 <20120524093713.59e3e497@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Jan Ceuleers <jan.ceuleers@computer.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54326 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758431Ab2EXRNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 13:13:31 -0400
In-Reply-To: <20120524093713.59e3e497@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No one uses this on current kernels anymore.

Let it be known it's going to be removed eventually.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Thu, 2012-05-24 at 09:37 -0700, Stephen Hemminger wrote:
> And add to Documentation/features-removal. Probably need a year of
> warning period.

feature-removal-schedule.txt needs work,
but OK, here it is.

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index 1e69a81..145cded 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -567,3 +567,9 @@ Why:	Remount currently allows changing bound subsystems and
 	replaced with conventional fsnotify.
 
 ----------------------------
+
+What:	net/wanrouter/
+When:	June 2013
+Why:	Unsupported/unmaintained/unused since 2.6
+
+----------------------------
diff --git a/net/wanrouter/Kconfig b/net/wanrouter/Kconfig
index 61ceae0..a157a2e 100644
--- a/net/wanrouter/Kconfig
+++ b/net/wanrouter/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config WAN_ROUTER
-	tristate "WAN router"
+	tristate "WAN router (DEPRECATED)"
 	depends on EXPERIMENTAL
 	---help---
 	  Wide Area Networks (WANs), such as X.25, frame relay and leased
