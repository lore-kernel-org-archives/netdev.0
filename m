From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] gigaset: Use semicolons to terminate statements
Date: Mon, 27 Feb 2012 09:39:27 -0800
Message-ID: <1330364367.9942.21.camel@joe2Laptop>
References: <4F4B45F6.4090706@suse.cz> <1330361549.9942.7.camel@joe2Laptop>
	 <4F4BB983.8020608@suse.cz> <1330363627.9942.16.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Tilman Schmidt <tilman@imap.cc>,
	gigaset307x-common@lists.sourceforge.net,
	David Miller <davem@davemloft.net>
To: Jiri Slaby <jslaby@suse.cz>, netdev <netdev@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330363627.9942.16.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commas are not generally used at locations where
statement termination semicolons are used.

Realign each field set at appropriate indentation.

Signed-off-by: Joe Perches <joe@perches.com>
---
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index da2486e..91f99e4 100644
@@ -679,10 +679,10 @@ void gigaset_if_initdriver(struct gigaset_driver *drv, const char *procname,
 	if (tty == NULL)
 		goto enomem;
 
-	tty->magic =		TTY_DRIVER_MAGIC,
-		tty->type =		TTY_DRIVER_TYPE_SERIAL,
-		tty->subtype =		SERIAL_TYPE_NORMAL,
-		tty->flags =		TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
+	tty->magic =		TTY_DRIVER_MAGIC;
+	tty->type =		TTY_DRIVER_TYPE_SERIAL;
+	tty->subtype =		SERIAL_TYPE_NORMAL;
+	tty->flags =		TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
 
 	tty->driver_name =	procname;
 	tty->name =		devname;
