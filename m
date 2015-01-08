From: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
Subject: [PATCH 15/15] batman-adv: Kconfig,
	Add missing DEBUG_FS dependency
Date: Thu,  8 Jan 2015 16:15:20 +0100
Message-ID: <1420730120-9844-16-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1420730120-9844-1-git-send-email-antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

BATMAN_ADV_DEBUG is using debugfs files for the debugging log. So it
depends on DEBUG_FS which is missing as dependency in the Kconfig file.

Signed-off-by: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Signed-off-by: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
---
 net/batman-adv/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 11660a3..c6fc8f7 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -62,6 +62,7 @@ config BATMAN_ADV_MCAST
 config BATMAN_ADV_DEBUG
 	bool "B.A.T.M.A.N. debugging"
 	depends on BATMAN_ADV
+	depends on DEBUG_FS
 	help
 	  This is an option for use by developers; most people should
 	  say N here. This enables compilation of support for
-- 
2.2.1
