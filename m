From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] rrunner: fix section references
Date: Sun, 27 Feb 2005 22:14:25 -0800
Message-ID: <20050227221425.38a12015.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, torvalds <torvalds@osdl.org>
To: netdev@oss.sgi.com, jgarzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


rrunner: references __initdata in a __devinit function; data should
  be __devinitdata;

Error: ./drivers/net/rrunner.o .text refers to 00000000000002b2 R_X86_64_32S      .init.data

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/rrunner.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/rrunner.c~rrunner_sections ./drivers/net/rrunner.c
--- ./drivers/net/rrunner.c~rrunner_sections	2004-12-24 13:34:26.000000000 -0800
+++ ./drivers/net/rrunner.c	2005-02-27 22:14:12.303076680 -0800
@@ -62,7 +62,7 @@ MODULE_AUTHOR("Jes Sorensen <jes@wildope
 MODULE_DESCRIPTION("Essential RoadRunner HIPPI driver");
 MODULE_LICENSE("GPL");
 
-static char version[] __initdata = "rrunner.c: v0.50 11/11/2002  Jes Sorensen (jes@wildopensource.com)\n";
+static char version[] __devinitdata = "rrunner.c: v0.50 11/11/2002  Jes Sorensen (jes@wildopensource.com)\n";
 
 /*
  * Implementation notes:


---
