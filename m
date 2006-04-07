From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 02/21] orinoco: remove PCMCIA audio support, it's useless for wireless cards
Date: Fri, 07 Apr 2006 04:10:21 -0400
Message-ID: <20060407081021.16107.81864.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
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

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco_cs.c  |    6 ------
 drivers/net/wireless/spectrum_cs.c |    6 ------
 2 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/ori=
noco_cs.c
index 05f1762..eda01a7 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -248,12 +248,6 @@ orinoco_cs_config(dev_link_t *link)
 			goto next_entry;
 		link->conf.ConfigIndex =3D cfg->index;
=20
-		/* Does this card need audio output? */
-		if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
-			link->conf.Attributes |=3D CONF_ENABLE_SPKR;
-			link->conf.Status =3D CCSR_AUDIO_ENA;
-		}
-
 		/* Use power settings for Vcc and Vpp if present */
 		/* Note that the CIS values need to be rescaled */
 		if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/sp=
ectrum_cs.c
index 87178a3..0b0bce7 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -721,12 +721,6 @@ spectrum_cs_config(dev_link_t *link)
 			goto next_entry;
 		link->conf.ConfigIndex =3D cfg->index;
=20
-		/* Does this card need audio output? */
-		if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
-			link->conf.Attributes |=3D CONF_ENABLE_SPKR;
-			link->conf.Status =3D CCSR_AUDIO_ENA;
-		}
-
 		/* Use power settings for Vcc and Vpp if present */
 		/* Note that the CIS values need to be rescaled */
 		if (cfg->vcc.present & (1 << CISTPL_POWER_VNOM)) {



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
