From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] networking: document "nc" in addition to "netcat" in
 netconsole.txt
Date: Fri, 23 Jan 2009 09:21:04 -0800
Message-ID: <20090123092104.64098f66.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Matt Mackall <mpm@selenic.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:40292 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbZAWRV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 12:21:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Barnes <jbarnes@virtuousgeek.org>

It always annoyed me that the netconsole documentation didn't give me the
correct command for my distro.  Update it with a command line that actually
works on my Fedora install.

Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
cc: Matt Mackall <mpm@selenic.com>
---
 Documentation/networking/netconsole.txt |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-next-20090123.orig/Documentation/networking/netconsole.txt
+++ linux-next-20090123/Documentation/networking/netconsole.txt
@@ -51,7 +51,8 @@ Built-in netconsole starts immediately a
 initialized and attempts to bring up the supplied dev at the supplied
 address.
 
-The remote host can run either 'netcat -u -l -p <port>' or syslogd.
+The remote host can run either 'netcat -u -l -p <port>',
+'nc -l -u <port>' or syslogd.
 
 Dynamic reconfiguration:
 ========================
