From: Peter Huewe <PeterHuewe@gmx.de>
Subject: [PATCH 23/25] isdn/hisax: Convert pci_table entries to PCI_VDEVICE (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 21:07:30 +0200
Message-ID: <201007152107.31524.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:38562 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S934334Ab0GOTHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jul 2010 15:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Huewe <peterhuewe@gmx.de>

This patch converts pci_table entries, where .subvendor=PCI_ANY_ID and
.subdevice=PCI_ANY_ID, .class=0 and .class_mask=0, to use the
PCI_VDEVICE macro, and thus improves readability.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/isdn/hisax/config.c |   84 +++++++++++++++++++++---------------------
 1 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index 544cf4b..f4ac548 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -1909,68 +1909,68 @@ static void EChannel_proc_rcv(struct hisax_d_if *d_if)
 
 static struct pci_device_id hisax_pci_tbl[] __devinitdata = {
 #ifdef CONFIG_HISAX_FRITZPCI
-	{PCI_VENDOR_ID_AVM,      PCI_DEVICE_ID_AVM_A1,           PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VDEVICE(AVM,      PCI_DEVICE_ID_AVM_A1)			},
 #endif
 #ifdef CONFIG_HISAX_DIEHLDIVA
-	{PCI_VENDOR_ID_EICON,    PCI_DEVICE_ID_EICON_DIVA20,     PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_EICON,    PCI_DEVICE_ID_EICON_DIVA20_U,   PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_EICON,    PCI_DEVICE_ID_EICON_DIVA201,    PCI_ANY_ID, PCI_ANY_ID},
-//#########################################################################################	
-	{PCI_VENDOR_ID_EICON,    PCI_DEVICE_ID_EICON_DIVA202,    PCI_ANY_ID, PCI_ANY_ID},
-//#########################################################################################	
+	{PCI_VDEVICE(EICON,    PCI_DEVICE_ID_EICON_DIVA20)		},
+	{PCI_VDEVICE(EICON,    PCI_DEVICE_ID_EICON_DIVA20_U)	},
+	{PCI_VDEVICE(EICON,    PCI_DEVICE_ID_EICON_DIVA201)		},
+/*##########################################################################*/
+	{PCI_VDEVICE(EICON,    PCI_DEVICE_ID_EICON_DIVA202)		},
+/*##########################################################################*/
 #endif
 #ifdef CONFIG_HISAX_ELSA
-	{PCI_VENDOR_ID_ELSA,     PCI_DEVICE_ID_ELSA_MICROLINK,   PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_ELSA,     PCI_DEVICE_ID_ELSA_QS3000,      PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VDEVICE(ELSA,     PCI_DEVICE_ID_ELSA_MICROLINK)	},
+	{PCI_VDEVICE(ELSA,     PCI_DEVICE_ID_ELSA_QS3000)		},
 #endif
 #ifdef CONFIG_HISAX_GAZEL
-	{PCI_VENDOR_ID_PLX,      PCI_DEVICE_ID_PLX_R685,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_PLX,      PCI_DEVICE_ID_PLX_R753,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_PLX,      PCI_DEVICE_ID_PLX_DJINN_ITOO,   PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_PLX,      PCI_DEVICE_ID_PLX_OLITEC,       PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VDEVICE(PLX,      PCI_DEVICE_ID_PLX_R685)			},
+	{PCI_VDEVICE(PLX,      PCI_DEVICE_ID_PLX_R753)			},
+	{PCI_VDEVICE(PLX,      PCI_DEVICE_ID_PLX_DJINN_ITOO)	},
+	{PCI_VDEVICE(PLX,      PCI_DEVICE_ID_PLX_OLITEC)		},
 #endif
 #ifdef CONFIG_HISAX_SCT_QUADRO
-	{PCI_VENDOR_ID_PLX,      PCI_DEVICE_ID_PLX_9050,         PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VDEVICE(PLX,      PCI_DEVICE_ID_PLX_9050)			},
 #endif
 #ifdef CONFIG_HISAX_NICCY
-	{PCI_VENDOR_ID_SATSAGEM, PCI_DEVICE_ID_SATSAGEM_NICCY,   PCI_ANY_ID,PCI_ANY_ID},
+	{PCI_VDEVICE(SATSAGEM, PCI_DEVICE_ID_SATSAGEM_NICCY)	},
 #endif
 #ifdef CONFIG_HISAX_SEDLBAUER
-	{PCI_VENDOR_ID_TIGERJET, PCI_DEVICE_ID_TIGERJET_100,     PCI_ANY_ID,PCI_ANY_ID},
+	{PCI_VDEVICE(TIGERJET, PCI_DEVICE_ID_TIGERJET_100)		},
 #endif
 #if defined(CONFIG_HISAX_NETJET) || defined(CONFIG_HISAX_NETJET_U)
-	{PCI_VENDOR_ID_TIGERJET, PCI_DEVICE_ID_TIGERJET_300,     PCI_ANY_ID,PCI_ANY_ID},
+	{PCI_VDEVICE(TIGERJET, PCI_DEVICE_ID_TIGERJET_300)		},
 #endif
 #if defined(CONFIG_HISAX_TELESPCI) || defined(CONFIG_HISAX_SCT_QUADRO)
-	{PCI_VENDOR_ID_ZORAN,    PCI_DEVICE_ID_ZORAN_36120,      PCI_ANY_ID,PCI_ANY_ID},
+	{PCI_VDEVICE(ZORAN,    PCI_DEVICE_ID_ZORAN_36120)		},
 #endif
 #ifdef CONFIG_HISAX_W6692
-	{PCI_VENDOR_ID_DYNALINK, PCI_DEVICE_ID_DYNALINK_IS64PH,  PCI_ANY_ID,PCI_ANY_ID},
-	{PCI_VENDOR_ID_WINBOND2, PCI_DEVICE_ID_WINBOND2_6692,    PCI_ANY_ID,PCI_ANY_ID},
+	{PCI_VDEVICE(DYNALINK, PCI_DEVICE_ID_DYNALINK_IS64PH)	},
+	{PCI_VDEVICE(WINBOND2, PCI_DEVICE_ID_WINBOND2_6692)		},
 #endif
 #ifdef CONFIG_HISAX_HFC_PCI
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_2BD0,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B000,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B006,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B007,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B008,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B009,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B00A,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B00B,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B00C,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B100,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B700,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_CCD,      PCI_DEVICE_ID_CCD_B701,         PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_ABOCOM,   PCI_DEVICE_ID_ABOCOM_2BD1,      PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_ASUSTEK,  PCI_DEVICE_ID_ASUSTEK_0675,     PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_BERKOM,   PCI_DEVICE_ID_BERKOM_T_CONCEPT, PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_BERKOM,   PCI_DEVICE_ID_BERKOM_A1T,       PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_ANIGMA,   PCI_DEVICE_ID_ANIGMA_MC145575,  PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_ZOLTRIX,  PCI_DEVICE_ID_ZOLTRIX_2BD0,     PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_DIGI,     PCI_DEVICE_ID_DIGI_DF_M_IOM2_E, PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_DIGI,     PCI_DEVICE_ID_DIGI_DF_M_E,      PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_DIGI,     PCI_DEVICE_ID_DIGI_DF_M_IOM2_A, PCI_ANY_ID, PCI_ANY_ID},
-	{PCI_VENDOR_ID_DIGI,     PCI_DEVICE_ID_DIGI_DF_M_A,      PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_2BD0)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B000)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B006)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B007)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B008)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B009)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B00A)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B00B)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B00C)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B100)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B700)			},
+	{PCI_VDEVICE(CCD,      PCI_DEVICE_ID_CCD_B701)			},
+	{PCI_VDEVICE(ABOCOM,   PCI_DEVICE_ID_ABOCOM_2BD1)		},
+	{PCI_VDEVICE(ASUSTEK,  PCI_DEVICE_ID_ASUSTEK_0675)		},
+	{PCI_VDEVICE(BERKOM,   PCI_DEVICE_ID_BERKOM_T_CONCEPT)	},
+	{PCI_VDEVICE(BERKOM,   PCI_DEVICE_ID_BERKOM_A1T)		},
+	{PCI_VDEVICE(ANIGMA,   PCI_DEVICE_ID_ANIGMA_MC145575)	},
+	{PCI_VDEVICE(ZOLTRIX,  PCI_DEVICE_ID_ZOLTRIX_2BD0)		},
+	{PCI_VDEVICE(DIGI,     PCI_DEVICE_ID_DIGI_DF_M_IOM2_E)	},
+	{PCI_VDEVICE(DIGI,     PCI_DEVICE_ID_DIGI_DF_M_E)		},
+	{PCI_VDEVICE(DIGI,     PCI_DEVICE_ID_DIGI_DF_M_IOM2_A)	},
+	{PCI_VDEVICE(DIGI,     PCI_DEVICE_ID_DIGI_DF_M_A)		},
 #endif
 	{ }				/* Terminating entry */
 };
-- 
1.7.1

