From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 24/26] drivers: isdn: Move prototype declaration to header
 file hisax.h from config.c
Date: Fri, 7 Feb 2014 18:17:52 +0530
Message-ID: <7a100c457a882b2de084a50bdbd8b65827dc7aaf.1390408519.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of functions to header file hisax/hisax.h
because they are used by more than one file.

This eliminates the following warnings:
drivers/isdn/hisax/teles3.c:273:5: warning: no previous prototype for =E2=
=80=98setup_teles3=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/telespci.c:288:5: warning: no previous prototype for=
 =E2=80=98setup_telespci=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/s0box.c:213:5: warning: no previous prototype for =E2=
=80=98setup_s0box=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/avm_a1p.c:216:5: warning: no previous prototype for =
=E2=80=98setup_avm_a1_pcmcia=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/avm_pci.c:870:5: warning: no previous prototype for =
=E2=80=98setup_avm_pcipnp=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/elsa.c:1209:5: warning: no previous prototype for =E2=
=80=98setup_elsa=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/diva.c:1241:5: warning: no previous prototype for =E2=
=80=98setup_diva=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/sedlbauer.c:674:5: warning: no previous prototype fo=
r =E2=80=98setup_sedlbauer=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/nj_s.c:258:5: warning: no previous prototype for =E2=
=80=98setup_netjet_s=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/nj_u.c:221:5: warning: no previous prototype for =E2=
=80=98setup_netjet_u=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/hfc_pci.c:1638:1: warning: no previous prototype for=
 =E2=80=98setup_hfcpci=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/hfc_sx.c:1395:5: warning: no previous prototype for =
=E2=80=98setup_hfcsx=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/niccy.c:229:5: warning: no previous prototype for =E2=
=80=98setup_niccy=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/bkm_a4t.c:325:5: warning: no previous prototype for =
=E2=80=98setup_bkm_a4t=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/bkm_a8.c:276:5: warning: no previous prototype for =E2=
=80=98setup_sct_quadro=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/gazel.c:623:5: warning: no previous prototype for =E2=
=80=98setup_gazel=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/w6692.c:996:5: warning: no previous prototype for =E2=
=80=98setup_w6692=E2=80=99 [-Wmissing-prototypes]
drivers/isdn/hisax/enternow_pci.c:387:5: warning: no previous prototype=
 for =E2=80=98setup_enternow_pci=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hisax/config.c |   72 -----------------------------------=
--------
 drivers/isdn/hisax/hisax.h  |   71 +++++++++++++++++++++++++++++++++++=
+++++++
 2 files changed, 71 insertions(+), 72 deletions(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index b33f53b..196cbb8 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -460,42 +460,14 @@ __setup("hisax=3D", HiSax_setup);
 extern int setup_teles0(struct IsdnCard *card);
 #endif
=20
-#if CARD_TELES3
-extern int setup_teles3(struct IsdnCard *card);
-#endif
-
-#if CARD_S0BOX
-extern int setup_s0box(struct IsdnCard *card);
-#endif
-
-#if CARD_TELESPCI
-extern int setup_telespci(struct IsdnCard *card);
-#endif
-
 #if CARD_AVM_A1
 extern int setup_avm_a1(struct IsdnCard *card);
 #endif
=20
-#if CARD_AVM_A1_PCMCIA
-extern int setup_avm_a1_pcmcia(struct IsdnCard *card);
-#endif
-
-#if CARD_FRITZPCI
-extern int setup_avm_pcipnp(struct IsdnCard *card);
-#endif
-
-#if CARD_ELSA
-extern int setup_elsa(struct IsdnCard *card);
-#endif
-
 #if CARD_IX1MICROR2
 extern int setup_ix1micro(struct IsdnCard *card);
 #endif
=20
-#if CARD_DIEHLDIVA
-extern int setup_diva(struct IsdnCard *card);
-#endif
-
 #if CARD_ASUSCOM
 extern int setup_asuscom(struct IsdnCard *card);
 #endif
@@ -504,10 +476,6 @@ extern int setup_asuscom(struct IsdnCard *card);
 extern int setup_TeleInt(struct IsdnCard *card);
 #endif
=20
-#if CARD_SEDLBAUER
-extern int setup_sedlbauer(struct IsdnCard *card);
-#endif
-
 #if CARD_SPORTSTER
 extern int setup_sportster(struct IsdnCard *card);
 #endif
@@ -516,26 +484,10 @@ extern int setup_sportster(struct IsdnCard *card)=
;
 extern int setup_mic(struct IsdnCard *card);
 #endif
=20
-#if CARD_NETJET_S
-extern int setup_netjet_s(struct IsdnCard *card);
-#endif
-
 #if CARD_HFCS
 extern int setup_hfcs(struct IsdnCard *card);
 #endif
=20
-#if CARD_HFC_PCI
-extern int setup_hfcpci(struct IsdnCard *card);
-#endif
-
-#if CARD_HFC_SX
-extern int setup_hfcsx(struct IsdnCard *card);
-#endif
-
-#if CARD_NICCY
-extern int setup_niccy(struct IsdnCard *card);
-#endif
-
 #if CARD_ISURF
 extern int setup_isurf(struct IsdnCard *card);
 #endif
@@ -544,30 +496,6 @@ extern int setup_isurf(struct IsdnCard *card);
 extern int setup_saphir(struct IsdnCard *card);
 #endif
=20
-#if CARD_BKM_A4T
-extern int setup_bkm_a4t(struct IsdnCard *card);
-#endif
-
-#if CARD_SCT_QUADRO
-extern int setup_sct_quadro(struct IsdnCard *card);
-#endif
-
-#if CARD_GAZEL
-extern int setup_gazel(struct IsdnCard *card);
-#endif
-
-#if CARD_W6692
-extern int setup_w6692(struct IsdnCard *card);
-#endif
-
-#if CARD_NETJET_U
-extern int setup_netjet_u(struct IsdnCard *card);
-#endif
-
-#if CARD_FN_ENTERNOW_PCI
-extern int setup_enternow_pci(struct IsdnCard *card);
-#endif
-
 /*
  * Find card with given driverId
  */
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 6ead6314..90d68d1 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -1327,6 +1327,77 @@ void release_tei(struct IsdnCardState *cs);
 char *HiSax_getrev(const char *revision);
 int TeiNew(void);
 void TeiFree(void);
+#if CARD_TELES3
+int setup_teles3(struct IsdnCard *card);
+#endif
+
+#if CARD_TELESPCI
+extern int setup_telespci(struct IsdnCard *card);
+#endif
+
+#if CARD_S0BOX
+extern int setup_s0box(struct IsdnCard *card);
+#endif
+
+#if CARD_AVM_A1_PCMCIA
+extern int setup_avm_a1_pcmcia(struct IsdnCard *card);
+#endif
+
+#if CARD_FRITZPCI
+extern int setup_avm_pcipnp(struct IsdnCard *card);
+#endif
+
+#if CARD_ELSA
+extern int setup_elsa(struct IsdnCard *card);
+#endif
+
+#if CARD_DIEHLDIVA
+extern int setup_diva(struct IsdnCard *card);
+#endif
+
+#if CARD_SEDLBAUER
+extern int setup_sedlbauer(struct IsdnCard *card);
+#endif
+
+#if CARD_NETJET_S
+extern int setup_netjet_s(struct IsdnCard *card);
+#endif
+
+#if CARD_HFC_PCI
+extern int setup_hfcpci(struct IsdnCard *card);
+#endif
+
+#if CARD_HFC_SX
+extern int setup_hfcsx(struct IsdnCard *card);
+#endif
+
+#if CARD_NICCY
+extern int setup_niccy(struct IsdnCard *card);
+#endif
+
+#if CARD_BKM_A4T
+extern int setup_bkm_a4t(struct IsdnCard *card);
+#endif
+
+#if CARD_SCT_QUADRO
+extern int setup_sct_quadro(struct IsdnCard *card);
+#endif
+
+#if CARD_GAZEL
+extern int setup_gazel(struct IsdnCard *card);
+#endif
+
+#if CARD_W6692
+extern int setup_w6692(struct IsdnCard *card);
+#endif
+
+#if CARD_NETJET_U
+extern int setup_netjet_u(struct IsdnCard *card);
+#endif
+
+#if CARD_FN_ENTERNOW_PCI
+extern int setup_enternow_pci(struct IsdnCard *card);
+#endif
=20
 #ifdef CONFIG_PCI
=20
--=20
1.7.9.5
