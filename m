From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 14/14] netconsole.txt: revision of examples for the receiver of kernel messages
Date: Fri, 10 Aug 2012 15:10:37 +0800
Message-ID: <1344582637-18261-15-git-send-email-amwang@redhat.com>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Cc: Dirk Gouders <gouders@et.bocholt.fh-gelsenkirchen.de>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963Ab2HJHLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 03:11:36 -0400
In-Reply-To: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Gouders <gouders@et.bocholt.fh-gelsenkirchen.de>

There are at least 4 implementations of netcat with the BSD-based
being the only one that has to be used without the -p switch to
specify the listening port.

Jan Engelhardt suggested to add an example for socat(1).

Signed-off-by: Dirk Gouders <gouders@et.bocholt.fh-gelsenkirchen.de>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 Documentation/networking/netconsole.txt |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
index 8d02207..2e9e0ae2 100644
--- a/Documentation/networking/netconsole.txt
+++ b/Documentation/networking/netconsole.txt
@@ -51,8 +51,23 @@ Built-in netconsole starts immediately after the TCP stack is
 initialized and attempts to bring up the supplied dev at the supplied
 address.
 
-The remote host can run either 'netcat -u -l -p <port>',
-'nc -l -u <port>' or syslogd.
+The remote host has several options to receive the kernel messages,
+for example:
+
+1) syslogd
+
+2) netcat
+
+   On distributions using a BSD-based netcat version (e.g. Fedora,
+   openSUSE and Ubuntu) the listening port must be specified without
+   the -p switch:
+
+   'nc -u -l -p <port>' / 'nc -u -l <port>' or
+   'netcat -u -l -p <port>' / 'netcat -u -l <port>'
+
+3) socat
+
+   'socat udp-recv:<port> -'
 
 Dynamic reconfiguration:
 ========================
-- 
1.7.7.6
