From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 3/8] orinoco: Remove entry for Intel PRO/Wireless 2011B.
Date: Thu, 01 Sep 2005 20:04:20 -0400
Message-ID: <1125619461.29016.0.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff-tree c88faac230cc9775445e5c644991c352e35c72a1 (from dce61aef99ceb57370b70222dc34d788666c0ac3)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Thu Sep 1 17:09:45 2005 -0400

    Remove entry for Intel PRO/Wireless 2011B.
    
    It is not supported by this driver because it has no firmware in
    flash.  spectrum_cs is needed for this device.

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -602,11 +602,10 @@ static char version[] __initdata = DRIVE
 	" (David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>, "
 	"Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>, et al)";
 
 static struct pcmcia_device_id orinoco_cs_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x000b, 0x7300),
-	PCMCIA_DEVICE_MANF_CARD(0x0089, 0x0001),
 	PCMCIA_DEVICE_MANF_CARD(0x0138, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0x0156, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0x01eb, 0x080a),
 	PCMCIA_DEVICE_MANF_CARD(0x0261, 0x0002),
 	PCMCIA_DEVICE_MANF_CARD(0x0268, 0x0001),


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
