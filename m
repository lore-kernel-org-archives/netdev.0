From: maximilian attems <janitor@sternwelten.at>
Subject: [patch-kj] mark __init/__exit static drivers/net/bsd_comp.c
Date: Mon, 21 Jun 2004 21:50:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621195059.GH1545@sputnik.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

more static, aplies on 2.6.7, 
compile tested

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>


---

 linux-2.6.7-max/drivers/net/bsd_comp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/bsd_comp.c~static-bsd_comp drivers/net/bsd_comp.c
--- linux-2.6.7/drivers/net/bsd_comp.c~static-bsd_comp	2004-06-18 09:21:30.000000000 +0200
+++ linux-2.6.7-max/drivers/net/bsd_comp.c	2004-06-18 09:21:30.000000000 +0200
@@ -1160,7 +1160,7 @@ static struct compressor ppp_bsd_compres
  * Module support routines
  *************************************************************/
 
-int __init bsdcomp_init(void)
+static int __init bsdcomp_init(void)
 {
 	int answer = ppp_register_compressor(&ppp_bsd_compress);
 	if (answer == 0)
@@ -1168,7 +1168,7 @@ int __init bsdcomp_init(void)
 	return answer;
 }
 
-void __exit bsdcomp_cleanup(void)
+static void __exit bsdcomp_cleanup(void)
 {
 	ppp_unregister_compressor(&ppp_bsd_compress);
 }
