From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [Patch]2.5.70 - display bootserver in /proc/net/pnp(net/ipv4/ipconfig.c)
 (fwd)
Date: Sat, 5 Jul 2003 12:52:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307051235450.25642-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <lode_leroy@hotmail.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

How about:


--- /usr/src/linux-2.5.73/net/ipv4/ipconfig.c	Sun Jun 22 11:32:31 2003
+++ /usr/src/linux-2.5.73/net/ipv4/ipconfig.c.new	Sat Jul  5 12:16:00 2003
@@ -1115,6 +1115,10 @@
 				       "nameserver %u.%u.%u.%u\n",
 				       NIPQUAD(ic_nameservers[i]));
 	}
+	if (ic_servaddr != INADDR_NONE)
+		len += sprintf(buffer + len,
+			       "bootserver %u.%u.%u.%u\n",
+			       NIPQUAD(ic_servaddr));
 
 	if (offset > len)
 		offset = len;
 

thanks,
Nivedita
