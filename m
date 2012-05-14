From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] dummy: documentation is stale
Date: Mon, 14 May 2012 14:57:31 +0100
Message-ID: <20120514135724.23177.91808.stgit@bluebook>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:43134 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab2ENN61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 09:58:27 -0400
Received: from [194.168.151.100] (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q4EESO2T018207
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 15:28:30 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

dummy0/1/2 names are always used and there are options to set multiple
dummy devices. Remove the obsolete text

Resolves-bug: https://bugzilla.kernel.org/show_bug.cgi?id=42865
Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/Kconfig |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b982854..78a6259 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -66,10 +66,7 @@ config DUMMY
 	  <http://www.tldp.org/docs.html#guide>.
 
 	  To compile this driver as a module, choose M here: the module
-	  will be called dummy.  If you want to use more than one dummy
-	  device at a time, you need to compile this driver as a module.
-	  Instead of 'dummy', the devices will then be called 'dummy0',
-	  'dummy1' etc.
+	  will be called dummy.
 
 config EQUALIZER
 	tristate "EQL (serial line load balancing) support"
