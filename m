From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (19/42) 3c515-T10
Date: Thu, 13 Nov 2003 11:32:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031113113239.0e781305.shemminger@osdl.org>
References: <200311130043.hAD0hSw30717@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <200311130043.hAD0hSw30717@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Also need this patch to the patch to allow 3c515 to be built as non-module.
Al added list of list which is needed by module, but
non-module might as well maintain it as well.

diff -Nru a/drivers/net/3c515.c b/drivers/net/3c515.c
--- a/drivers/net/3c515.c	Thu Nov 13 10:46:27 2003
+++ b/drivers/net/3c515.c	Thu Nov 13 10:46:27 2003
@@ -407,11 +407,12 @@
 /* Note: this is the only limit on the number of cards supported!! */
 static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1, };
 
-#ifdef MODULE
-static int debug = -1;
 /* A list of all installed Vortex devices, for removing the driver module. */
 /* we will need locking (and refcounting) if we ever use it for more */
 static LIST_HEAD(root_corkscrew_dev);
+
+#ifdef MODULE
+static int debug = -1;
 
 int init_module(void)
 {
