From: Meelis Roos <mroos@linux.ee>
Subject: Quieten privacy extensions message
Date: Wed, 16 Feb 2005 19:27:40 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0502161924050.17280@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's not nice to see kernel internal pointers like this in dmesg:
Disabled Privacy Extensions on device 00000000006a2970(lo)

The patch removes the pointer from dmesg, resulting in
Disabled Privacy Extensions on device lo

Signed-off-by: Meelis Roos <mroos@linux.ee>

===== net/ipv6/addrconf.c 1.129 vs edited =====
--- 1.129/net/ipv6/addrconf.c	2005-01-17 23:13:31 +02:00
+++ edited/net/ipv6/addrconf.c	2005-02-16 19:21:59 +02:00
@@ -364,8 +364,8 @@
  		    dev->type == ARPHRD_TUNNEL ||
  		    dev->type == ARPHRD_SIT) {
  			printk(KERN_INFO
-				"Disabled Privacy Extensions on device %p(%s)\n",
-				dev, dev->name);
+				"Disabled Privacy Extensions on device %s\n",
+				dev->name);
  			ndev->cnf.use_tempaddr = -1;
  		} else {
  			in6_dev_hold(ndev);

-- 
Meelis Roos (mroos@linux.ee)
