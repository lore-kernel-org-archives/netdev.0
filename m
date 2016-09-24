From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH 3/6] isdn/hisax: add function declarations
Date: Sat, 24 Sep 2016 13:21:47 +0800
Message-ID: <1474694507-7379-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: isdn@linux-pingi.de, linux-kernel.bfrz@manchmal.in-ulm.de,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a few warnings when building kernel with W=1:
drivers/isdn/hisax/teles3.c:273:5: warning: no previous prototype for 'setup_teles3' [-Wmissing-prototypes]
drivers/isdn/hisax/s0box.c:213:5: warning: no previous prototype for 'setup_s0box' [-Wmissing-prototypes]
drivers/isdn/hisax/bkm_a4t.c:325:5: warning: no previous prototype for 'setup_bkm_a4t' [-Wmissing-prototypes]
drivers/isdn/hisax/w6692.c:996:5: warning: no previous prototype for 'setup_w6692' [-Wmissing-prototypes]
....

In fact, these functions need be declared in some header files.

So this patch adds function declarations in drivers/isdn/hisax/hisax.h.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/isdn/hisax/config.c | 60 ---------------------------------------------
 drivers/isdn/hisax/hisax.h  | 60 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+), 60 deletions(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index bf04d2a..5335c8b 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -460,42 +460,14 @@ __setup("hisax=", HiSax_setup);
 extern int setup_teles0(struct IsdnCard *card);
 #endif
 
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
 
-#if CARD_SEDLBAUER
-extern int setup_sedlbauer(struct IsdnCard *card);
-#endif
-
 #if CARD_SPORTSTER
 extern int setup_sportster(struct IsdnCard *card);
 #endif
@@ -524,18 +492,6 @@ extern int setup_netjet_s(struct IsdnCard *card);
 extern int setup_hfcs(struct IsdnCard *card);
 #endif
 
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
@@ -544,22 +500,6 @@ extern int setup_isurf(struct IsdnCard *card);
 extern int setup_saphir(struct IsdnCard *card);
 #endif
 
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
 #if CARD_NETJET_U
 extern int setup_netjet_u(struct IsdnCard *card);
 #endif
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 6ead6314..7e1d2a6 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -1350,3 +1350,63 @@ static inline struct pci_dev *hisax_find_pci_device(unsigned int vendor,
 }
 
 #endif
+
+#if CARD_TELES3
+int setup_teles3(struct IsdnCard *card);
+#endif
+
+#if CARD_TELESPCI
+int setup_telespci(struct IsdnCard *card);
+#endif
+
+#if CARD_S0BOX
+int setup_s0box(struct IsdnCard *card);
+#endif
+
+#if CARD_AVM_A1_PCMCIA
+int setup_avm_a1_pcmcia(struct IsdnCard *card);
+#endif
+
+#if CARD_FRITZPCI
+int setup_avm_pcipnp(struct IsdnCard *card);
+#endif
+
+#if CARD_ELSA
+int setup_elsa(struct IsdnCard *card);
+#endif
+
+#if CARD_DIEHLDIVA
+int setup_diva(struct IsdnCard *card);
+#endif
+
+#if CARD_SEDLBAUER
+int setup_sedlbauer(struct IsdnCard *card);
+#endif
+
+#if CARD_HFC_PCI
+int setup_hfcpci(struct IsdnCard *card);
+#endif
+
+#if CARD_HFC_SX
+int setup_hfcsx(struct IsdnCard *card);
+#endif
+
+#if CARD_NICCY
+int setup_niccy(struct IsdnCard *card);
+#endif
+
+#if CARD_BKM_A4T
+int setup_bkm_a4t(struct IsdnCard *card);
+#endif
+
+#if CARD_SCT_QUADRO
+int setup_sct_quadro(struct IsdnCard *card);
+#endif
+
+#if CARD_GAZEL
+int setup_gazel(struct IsdnCard *card);
+#endif
+
+#if CARD_W6692
+int setup_w6692(struct IsdnCard *card);
+#endif
-- 
2.7.4
