From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH v2] docbook: fix printk of ip address
Date: Thu, 30 Jul 2009 12:37:46 -0700
Message-ID: <20090730123746.1fe58340.randy.dunlap@oracle.com>
References: <20090730122518.995a83ba.randy.dunlap@oracle.com>
	<20090730.123151.191002348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tklauser@distanz.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51759 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbZG3TiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 15:38:07 -0400
In-Reply-To: <20090730.123151.191002348.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>

Use the %pI4 format string instead of %d.%d.%d.%d and NIPQUAD.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 Documentation/DocBook/kernel-hacking.tmpl |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.31-rc4-git3.orig/Documentation/DocBook/kernel-hacking.tmpl
+++ linux-2.6.31-rc4-git3/Documentation/DocBook/kernel-hacking.tmpl
@@ -449,8 +449,8 @@ printk(KERN_INFO "i = %u\n", i);
    </para>
 
    <programlisting>
-__u32 ipaddress;
-printk(KERN_INFO "my ip: %d.%d.%d.%d\n", NIPQUAD(ipaddress));
+__be32 ipaddress;
+printk(KERN_INFO "my ip: %pI4\n", &amp;ipaddress);
    </programlisting>
 
    <para>



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
