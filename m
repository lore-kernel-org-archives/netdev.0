From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] isdn/hisax: fix compiler warning on hisax_pci_tbl
Date: Tue,  7 Dec 2010 23:49:06 +0900
Message-ID: <1291733346-11573-1-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Annotate hisax_pci_tbl as '__used' to fix following warning:

  CC      drivers/isdn/hisax/config.o
drivers/isdn/hisax/config.c:1920: warning: =E2=80=98hisax_pci_tbl=E2=80=
=99 defined but not used

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 drivers/isdn/hisax/config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index b133378..c110f86 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -1917,7 +1917,7 @@ static void EChannel_proc_rcv(struct hisax_d_if *=
d_if)
 #ifdef CONFIG_PCI
 #include <linux/pci.h>
=20
-static struct pci_device_id hisax_pci_tbl[] __devinitdata =3D {
+static struct pci_device_id hisax_pci_tbl[] __devinitdata __used =3D {
 #ifdef CONFIG_HISAX_FRITZPCI
 	{PCI_VDEVICE(AVM,      PCI_DEVICE_ID_AVM_A1)			},
 #endif
--=20
1.7.0.4
