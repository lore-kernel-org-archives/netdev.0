From: John Levon <levon@movementarian.org>
Subject: Re: [PATCH][ATM] a few patches from John Levon
Date: Fri, 5 Sep 2003 10:55:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905095539.GD38861@compsoc.man.ac.uk>
References: <200309041917.h84JHrSa020864@ginger.cmf.nrl.navy.mil> <20030905023536.68e808e7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030905023536.68e808e7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 05, 2003 at 02:35:36AM -0700, David S. Miller wrote:

> All applied, although:
> 
> > # [ATM]: fix atm_dev module refcount bug (from levon@movementarian.org)
> 
> You included this patch twice :-)

Hmm, then I think you're missing patch 5 :


diff -Naur -X dontdiff linux-cvs/net/atm/pppoatm.c linux-fixes/net/atm/pppoatm.c
--- linux-cvs/net/atm/pppoatm.c	2003-08-29 16:57:07.000000000 +0100
+++ linux-fixes/net/atm/pppoatm.c	2003-09-04 10:51:19.000000000 +0100
@@ -341,16 +341,13 @@
 	return -ENOIOCTLCMD;
 }
 
-/* the following avoids some spurious warnings from the compiler */
-#define UNUSED __attribute__((unused))
-
-static int __init UNUSED pppoatm_init(void)
+static int __init pppoatm_init(void)
 {
 	pppoatm_ioctl_set(pppoatm_ioctl);
 	return 0;
 }
 
-static void __exit UNUSED pppoatm_exit(void)
+static void __exit pppoatm_exit(void)
 {
 	pppoatm_ioctl_set(NULL);
 }
