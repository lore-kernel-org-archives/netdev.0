From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH 2.5.68] sysctl max_dgram_qlen permissions
Date: Fri, 2 May 2003 15:41:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0305021508540.3694-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Currently the sysctl var net.unix.max_dgram_qlen has 
0600 permissions..Need users to be able to read it..
Dont see any reason not to(?).

thanks,
Nivedita

--- sysctl_net_unix.c	Sat Apr 19 19:49:10 2003
+++ sysctl_net_unix.c.new	Fri May  2 13:48:11 2003
@@ -20,7 +20,7 @@
 		.procname	= "max_dgram_qlen",
 		.data		= &sysctl_unix_max_dgram_qlen,
 		.maxlen		= sizeof(int),
-		.mode		= 0600,
+		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
 	{ .ctl_name = 0 }
