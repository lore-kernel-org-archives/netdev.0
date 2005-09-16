From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 3/5] orinoco: Update PCMCIA ID's.
Date: Fri, 16 Sep 2005 02:18:31 -0400
Message-ID: <1126851511.3056.8.camel@dv>
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

diff-tree 73e242a82f9f4764e5381c1a5150909e17e01f94 (from 0f6bb198d92cc7e2351dd65528d86305f77aa7aa)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Fri Sep 16 01:07:47 2005 -0400

    Update PCMCIA ID's.
    
    Intel Pro/Wireless 2011 and 2011B have the same numeric ID, so use
    strings instead.
    
    Take all entries from *.conf for Orinoco, HostAP and linux-wlan-ng and
    adds them with minimal changes (e.g. we don't need a revision string
    after a string that identifies the chipset).
    
    Add comments with card names to all numeric entries.  Note: the comments
    don't and cannot cover all cards, since the main reason of having
    numeric IDs is to cover cards that are often rebranded.

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -598,53 +598,89 @@ orinoco_cs_event(event_t event, int prio
 static char version[] __initdata = DRIVER_NAME " " DRIVER_VERSION
 	" (David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>, "
 	"Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>, et al)";
 
 static struct pcmcia_device_id orinoco_cs_ids[] = {
-	PCMCIA_DEVICE_MANF_CARD(0x000b, 0x7300),
-	PCMCIA_DEVICE_MANF_CARD(0x0138, 0x0002),
-	PCMCIA_DEVICE_MANF_CARD(0x0156, 0x0002),
-	PCMCIA_DEVICE_MANF_CARD(0x01eb, 0x080a),
-	PCMCIA_DEVICE_MANF_CARD(0x0261, 0x0002),
-	PCMCIA_DEVICE_MANF_CARD(0x0268, 0x0001),
-	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0305),
-	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1613),
-	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0002),
-	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0673),
-	PCMCIA_DEVICE_MANF_CARD(0x02aa, 0x0002),
-	PCMCIA_DEVICE_MANF_CARD(0x02ac, 0x0002),
-	PCMCIA_DEVICE_MANF_CARD(0x14ea, 0xb001),
-	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x7300),
-	PCMCIA_DEVICE_MANF_CARD(0x9005, 0x0021),
-	PCMCIA_DEVICE_MANF_CARD(0xc250, 0x0002),
-	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002),
-	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0005),
+	PCMCIA_DEVICE_MANF_CARD(0x000b, 0x7100), /* SonicWALL Long Range Wireless Card */
+	PCMCIA_DEVICE_MANF_CARD(0x000b, 0x7300), /* Sohoware NCP110, Philips 802.11b */
+	PCMCIA_DEVICE_MANF_CARD(0x0089, 0x0002), /* AnyPoint(TM) Wireless II PC Card */
+	PCMCIA_DEVICE_MANF_CARD(0x0101, 0x0777), /* 3Com AirConnect PCI 777A */
+	PCMCIA_DEVICE_MANF_CARD(0x0126, 0x8000), /* PROXIM RangeLAN-DS/LAN PC CARD */
+	PCMCIA_DEVICE_MANF_CARD(0x0138, 0x0002), /* Compaq WL100 11 Mbps Wireless Adapter */
+	PCMCIA_DEVICE_MANF_CARD(0x0156, 0x0002), /* Lucent Orinoco and old Intersil */
+	PCMCIA_DEVICE_MANF_CARD(0x016b, 0x0001), /* Ericsson WLAN Card C11 */
+	PCMCIA_DEVICE_MANF_CARD(0x01eb, 0x080a), /* Nortel Networks eMobility 802.11 Wireless Adapter */
+	PCMCIA_DEVICE_MANF_CARD(0x01ff, 0x0008), /* Intermec MobileLAN 11Mbps 802.11b WLAN Card */
+	PCMCIA_DEVICE_MANF_CARD(0x0250, 0x0002), /* Samsung SWL2000-N 11Mb/s WLAN Card */
+	PCMCIA_DEVICE_MANF_CARD(0x0261, 0x0002), /* AirWay 802.11 Adapter (PCMCIA) */
+	PCMCIA_DEVICE_MANF_CARD(0x0268, 0x0001), /* ARtem Onair */
+	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0305), /* Buffalo WLI-PCM-S11 */
+	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1612), /* Linksys WPC11 Version 2.5 */
+	PCMCIA_DEVICE_MANF_CARD(0x0274, 0x1613), /* Linksys WPC11 Version 3 */
+	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0002), /* Compaq HNW-100 11 Mbps Wireless Adapter */
+	PCMCIA_DEVICE_MANF_CARD(0x028a, 0x0673), /* Linksys WCF12 Wireless CompactFlash Card */
+	PCMCIA_DEVICE_MANF_CARD(0x02aa, 0x0002), /* ASUS SpaceLink WL-100 */
+	PCMCIA_DEVICE_MANF_CARD(0x02ac, 0x0002), /* SpeedStream SS1021 Wireless Adapter */
+	PCMCIA_DEVICE_MANF_CARD(0x14ea, 0xb001), /* PLANEX RoadLannerWave GW-NS11H */
+	PCMCIA_DEVICE_MANF_CARD(0x50c2, 0x7300), /* Airvast WN-100 */
+	PCMCIA_DEVICE_MANF_CARD(0x9005, 0x0021), /* Adaptec Ultra Wireless ANW-8030 */
+	PCMCIA_DEVICE_MANF_CARD(0xc001, 0x0008), /* CONTEC FLEXSCAN/FX-DDS110-PCC */
+	PCMCIA_DEVICE_MANF_CARD(0xc250, 0x0002), /* Conceptronic CON11Cpro, EMTAC A2424i */
+	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002), /* Safeway 802.11b, ZCOMAX AirRunner/XI-300 */
+	PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0005), /* D-Link DCF660, Sandisk Connect SDWCFB-000 */
+	PCMCIA_DEVICE_PROD_ID12(" ", "IEEE 802.11 Wireless LAN/PC Card", 0x3b6e20c8, 0xefccafe9),
 	PCMCIA_DEVICE_PROD_ID12("3Com", "3CRWE737A AirConnect Wireless LAN PC Card", 0x41240e5b, 0x56010af3),
-	PCMCIA_DEVICE_PROD_ID123("Instant Wireless ", " Network PC CARD", "Version 01.02", 0x11d901af, 0x6e9bd926, 0x4b74baa0),
 	PCMCIA_DEVICE_PROD_ID12("ACTIONTEC", "PRISM Wireless LAN PC Card", 0x393089da, 0xa71e69d5),
+	PCMCIA_DEVICE_PROD_ID12("Addtron", "AWP-100 Wireless PCMCIA", 0xe6ec52ce, 0x08649af2),
+	PCMCIA_DEVICE_PROD_ID123("AIRVAST", "IEEE 802.11b Wireless PCMCIA Card", "HFA3863", 0xea569531, 0x4bcb9645, 0x355cb092),
+	PCMCIA_DEVICE_PROD_ID12("Allied Telesyn", "AT-WCL452 Wireless PCMCIA Radio", 0x5cd01705, 0x4271660f),
+	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11b_PC_CARD_25", 0x78fc06ee, 0xdb9aa842),
+	PCMCIA_DEVICE_PROD_ID12("ASUS", "802_11B_CF_CARD_25", 0x78fc06ee, 0x45a50c1e),
 	PCMCIA_DEVICE_PROD_ID12("Avaya Communication", "Avaya Wireless PC Card", 0xd8a43b78, 0x0d341169),
+	PCMCIA_DEVICE_PROD_ID12("BENQ", "AWL100 PCMCIA ADAPTER", 0x35dadc74, 0x01f7fedb),
 	PCMCIA_DEVICE_PROD_ID12("BUFFALO", "WLI-PCM-L11G", 0x2decece3, 0xf57ca4b3),
+	PCMCIA_DEVICE_PROD_ID12("BUFFALO", "WLI-CF-S11G", 0x2decece3, 0x82067c18),
 	PCMCIA_DEVICE_PROD_ID12("Cabletron", "RoamAbout 802.11 DS", 0x32d445f5, 0xedeffd90),
+	PCMCIA_DEVICE_PROD_ID12("Compaq", "WL200_11Mbps_Wireless_PCI_Card", 0x54f7c49c, 0x15a75e5b),
+	PCMCIA_DEVICE_PROD_ID123("corega", "WL PCCL-11", "ISL37300P", 0x0a21501a, 0x59868926, 0xc9049a39),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "Wireless LAN PCC-11", 0x5261440f, 0xa6405584),
 	PCMCIA_DEVICE_PROD_ID12("corega K.K.", "Wireless LAN PCCA-11", 0x5261440f, 0xdf6115f9),
 	PCMCIA_DEVICE_PROD_ID12("corega_K.K.", "Wireless_LAN_PCCB-11", 0x29e33311, 0xee7a27ae),
 	PCMCIA_DEVICE_PROD_ID12("D", "Link DRC-650 11Mbps WLAN Card", 0x71b18589, 0xf144e3ac),
 	PCMCIA_DEVICE_PROD_ID12("D", "Link DWL-650 11Mbps WLAN Card", 0x71b18589, 0xb6f1b0ab),
+	PCMCIA_DEVICE_PROD_ID12("D-Link Corporation", "D-Link DWL-650H 11Mbps WLAN Adapter", 0xef544d24, 0xcd8ea916),
+	PCMCIA_DEVICE_PROD_ID12("Digital Data Communications", "WPC-0100", 0xfdd73470, 0xe0b6f146),
 	PCMCIA_DEVICE_PROD_ID12("ELSA", "AirLancer MC-11", 0x4507a33a, 0xef54f0e3),
 	PCMCIA_DEVICE_PROD_ID12("HyperLink", "Wireless PC Card 11Mbps", 0x56cc3f1a, 0x0bcf220c),
+	PCMCIA_DEVICE_PROD_ID123("Instant Wireless ", " Network PC CARD", "Version 01.02", 0x11d901af, 0x6e9bd926, 0x4b74baa0),
+	PCMCIA_DEVICE_PROD_ID12("Intel", "PRO/Wireless 2011 LAN PC Card", 0x816cc815, 0x07f58077),
 	PCMCIA_DEVICE_PROD_ID12("INTERSIL", "HFA384x/IEEE", 0x74c5e40d, 0xdb472a18),
+	PCMCIA_DEVICE_PROD_ID12("INTERSIL", "I-GATE 11M PC Card / PC Card plus", 0x74c5e40d, 0x8304ff77),
+	PCMCIA_DEVICE_PROD_ID12("Intersil", "PRISM 2_5 PCMCIA ADAPTER", 0x4b801a17, 0x6345a0bf),
+	PCMCIA_DEVICE_PROD_ID123("Intersil", "PRISM Freedom PCMCIA Adapter", "ISL37100P", 0x4b801a17, 0xf222ec2d, 0x630d52b2),
+	PCMCIA_DEVICE_PROD_ID12("LeArtery", "SYNCBYAIR 11Mbps Wireless LAN PC Card", 0x7e3b326a, 0x49893e92),
+	PCMCIA_DEVICE_PROD_ID12("Linksys", "Wireless CompactFlash Card", 0x0733cc81, 0x0c52f395),
 	PCMCIA_DEVICE_PROD_ID12("Lucent Technologies", "WaveLAN/IEEE", 0x23eb9949, 0xc562e72a),
 	PCMCIA_DEVICE_PROD_ID12("MELCO", "WLI-PCM-L11", 0x481e0094, 0x7360e410),
 	PCMCIA_DEVICE_PROD_ID12("MELCO", "WLI-PCM-L11G", 0x481e0094, 0xf57ca4b3),
 	PCMCIA_DEVICE_PROD_ID12("Microsoft", "Wireless Notebook Adapter MN-520", 0x5961bf85, 0x6eec8c01),
 	PCMCIA_DEVICE_PROD_ID12("NCR", "WaveLAN/IEEE", 0x24358cd4, 0xc562e72a),
+	PCMCIA_DEVICE_PROD_ID12("NETGEAR MA401 Wireless PC", "Card", 0xa37434e9, 0x9762e8f1),
 	PCMCIA_DEVICE_PROD_ID12("NETGEAR MA401RA Wireless PC", "Card", 0x0306467f, 0x9762e8f1),
+	PCMCIA_DEVICE_PROD_ID12("Nortel Networks", "emobility 802.11 Wireless LAN PC Card", 0x2d617ea0, 0x88cd5767),
+	PCMCIA_DEVICE_PROD_ID12("OEM", "PRISM2 IEEE 802.11 PC-Card", 0xfea54c90, 0x48f2bdd6),
+	PCMCIA_DEVICE_PROD_ID12("OTC", "Wireless AirEZY 2411-PCC WLAN Card", 0x4ac44287, 0x235a6bed),
+	PCMCIA_DEVICE_PROD_ID123("PCMCIA", "11M WLAN Card v2.5", "ISL37300P", 0x281f1c5d, 0x6e440487, 0xc9049a39),
 	PCMCIA_DEVICE_PROD_ID12("PLANEX", "GeoWave/GW-CF110", 0x209f40ab, 0xd9715264),
+	PCMCIA_DEVICE_PROD_ID12("PLANEX", "GeoWave/GW-NS110", 0x209f40ab, 0x46263178),
 	PCMCIA_DEVICE_PROD_ID12("PROXIM", "LAN PC CARD HARMONY 80211B", 0xc6536a5e, 0x090c3cd9),
 	PCMCIA_DEVICE_PROD_ID12("PROXIM", "LAN PCI CARD HARMONY 80211B", 0xc6536a5e, 0x9f494e26),
 	PCMCIA_DEVICE_PROD_ID12("SAMSUNG", "11Mbps WLAN Card", 0x43d74cb4, 0x579bd91b),
-	PCMCIA_DEVICE_PROD_ID1("Symbol Technologies", 0x3f02b4d6),
+	PCMCIA_DEVICE_PROD_ID12("SMC", "SMC2632W", 0xc4f8b18b, 0x474a1f2a),
+	PCMCIA_DEVICE_PROD_ID12("Symbol Technologies", "LA4111 Spectrum24 Wireless LAN PC Card", 0x3f02b4d6, 0x3663cb0e),
+	PCMCIA_DEVICE_PROD_ID123("The Linksys Group, Inc.", "Instant Wireless Network PC Card", "ISL37300P", 0xa5f472c2, 0x590eb502, 0xc9049a39),
+	PCMCIA_DEVICE_PROD_ID12("ZoomAir 11Mbps High", "Rate wireless Networking", 0x273fe3db, 0x32a1eaee),
 	PCMCIA_DEVICE_NULL,
 };
 MODULE_DEVICE_TABLE(pcmcia, orinoco_cs_ids);
 
 static struct pcmcia_driver orinoco_driver = {
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -1059,11 +1059,11 @@ static char version[] __initdata = DRIVE
 	" David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>, et al)";
 
 static struct pcmcia_device_id spectrum_cs_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x026c, 0x0001), /* Symbol Spectrum24 LA4100 */
 	PCMCIA_DEVICE_MANF_CARD(0x0104, 0x0001), /* Socket Communications CF */
-	PCMCIA_DEVICE_MANF_CARD(0x0089, 0x0001), /* Intel PRO/Wireless 2011B */
+	PCMCIA_DEVICE_PROD_ID12("Intel", "PRO/Wireless LAN PC Card", 0x816cc815, 0x6fbf459a), /* 2011B, not 2011 */
 	PCMCIA_DEVICE_NULL,
 };
 MODULE_DEVICE_TABLE(pcmcia, spectrum_cs_ids);
 
 static struct pcmcia_driver orinoco_driver = {



-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
