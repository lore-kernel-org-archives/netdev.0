From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATH] atm/clip device discovery on init not needed
Date: Thu, 15 Jan 2004 14:59:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115145925.54eaf01a.shemminger@osdl.org>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
	<20040113163631.1a9c1a59.davem@redhat.com>
	<20040114164338.1f0d15e4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        chas williams
 <chas@cmf.nrl.navy.mil>,
        linux-atm-general@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040114164338.1f0d15e4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Forgot to resulting unused declaration.
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Thu Jan 15 14:49:45 2004
+++ b/net/atm/clip.c	Thu Jan 15 14:49:45 2004
@@ -731,8 +731,6 @@
 
 static int atm_init_atmarp(struct atm_vcc *vcc)
 {
-	struct net_device *dev;
-
 	if (atmarpd) return -EADDRINUSE;
 	if (start_timer) {
 		start_timer = 0;
