From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] 2.6.1-rc1-mm1 - typo of death in the r8169 driver
Date: Mon, 5 Jan 2004 23:17:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040105231741.A19514@electric-eye.fr.zoreil.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <20031126004550.A25408@electric-eye.fr.zoreil.com> <20031127235143.A16767@electric-eye.fr.zoreil.com> <20031130014738.A2589@electric-eye.fr.zoreil.com> <3FF846C3.5070207@mainstreetsoftworks.com> <20040104233849.A3214@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Brad House <brad@mainstreetsoftworks.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20040104233849.A3214@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sun, Jan 04, 2004 at 11:38:49PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

  silly bug in the r8169 driver.

Please apply, thanks.

--
Ueimor

--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-rx-fill-typo.patch"


Oops...


 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/r8169.c~r8169-rx-fill-typo drivers/net/r8169.c
--- linux-2.6.1-rc1-mm1/drivers/net/r8169.c~r8169-rx-fill-typo	2004-01-05 22:55:24.000000000 +0100
+++ linux-2.6.1-rc1-mm1-fr/drivers/net/r8169.c	2004-01-05 23:03:39.000000000 +0100
@@ -1186,7 +1186,7 @@ static u32 rtl8169_rx_fill(struct rtl816
 {
 	u32 cur;
 	
-	for (cur = start; end - start > 0; cur++) {
+	for (cur = start; end - cur > 0; cur++) {
 		int ret, i = cur % NUM_RX_DESC;
 
 		if (tp->Rx_skbuff[i])

_

--45Z9DzgjV8m4Oswq--
