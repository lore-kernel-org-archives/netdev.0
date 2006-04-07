From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 01/21] orinoco: Remove useless CIS validation
Date: Fri, 07 Apr 2006 04:10:19 -0400
Message-ID: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

The PCMCIA drivers would never be loaded if the CIS were wrong.
No other PCMCIA drivers validate CIS.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco_cs.c  |    3 ---
 drivers/net/wireless/spectrum_cs.c |    3 ---
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/ori=
noco_cs.c
index ec6f2a4..05f1762 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -191,12 +191,9 @@ orinoco_cs_config(dev_link_t *link)
 	int last_fn, last_ret;
 	u_char buf[64];
 	config_info_t conf;
-	cisinfo_t info;
 	tuple_t tuple;
 	cisparse_t parse;
 	void __iomem *mem;
-
-	CS_CHECK(ValidateCIS, pcmcia_validate_cis(handle, &info));
=20
 	/*
 	 * This reads the card's CONFIG tuple to find its
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/sp=
ectrum_cs.c
index 5fa6fbe..87178a3 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -664,12 +664,9 @@ spectrum_cs_config(dev_link_t *link)
 	int last_fn, last_ret;
 	u_char buf[64];
 	config_info_t conf;
-	cisinfo_t info;
 	tuple_t tuple;
 	cisparse_t parse;
 	void __iomem *mem;
-
-	CS_CHECK(ValidateCIS, pcmcia_validate_cis(handle, &info));
=20
 	/*
 	 * This reads the card's CONFIG tuple to find its



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
