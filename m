From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] docbook: fix printk of ip address
Date: Thu, 30 Jul 2009 12:25:18 -0700
Message-ID: <20090730122518.995a83ba.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Tobias Klauser <tklauser@distanz.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:61837 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbZG3TZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 15:25:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does this need to be changed to __be32?

---
From: Tobias Klauser <tklauser@distanz.ch>

Use the %pI4 format string instead of %d.%d.%d.%d and NIPQUAD.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 Documentation/DocBook/kernel-hacking.tmpl |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.31-rc4-git3.orig/Documentation/DocBook/kernel-hacking.tmpl
+++ linux-2.6.31-rc4-git3/Documentation/DocBook/kernel-hacking.tmpl
@@ -450,7 +450,7 @@ printk(KERN_INFO "i = %u\n", i);
 
    <programlisting>
 __u32 ipaddress;
-printk(KERN_INFO "my ip: %d.%d.%d.%d\n", NIPQUAD(ipaddress));
+printk(KERN_INFO "my ip: %pI4\n", &amp;ipaddress);
    </programlisting>
 
    <para>



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
