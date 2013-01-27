From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] net: iwlegacy: remove unused variable
Date: Sun, 27 Jan 2013 10:55:41 -0800
Message-ID: <1359312941-30661-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46ix:

drivers/net/wireless/iwlegacy/4965.c: In function =E2=80=98il4965_post_=
associate=E2=80=99:
drivers/net/wireless/iwlegacy/4965.c:1751:25: warning: variable =E2=80=98=
conf=E2=80=99 set but
not used [-Wunused-but-set-variable]

seen when building allmodconfig on x86_64 with W=3D1 by removing the un=
used
variable.

Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/iwlegacy/4965.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/4965.c b/drivers/net/wireles=
s/iwlegacy/4965.c
index 5db1171..91eb2d0 100644
--- a/drivers/net/wireless/iwlegacy/4965.c
+++ b/drivers/net/wireless/iwlegacy/4965.c
@@ -1748,7 +1748,6 @@ static void
 il4965_post_associate(struct il_priv *il)
 {
 	struct ieee80211_vif *vif =3D il->vif;
-	struct ieee80211_conf *conf =3D NULL;
 	int ret =3D 0;
=20
 	if (!vif || !il->is_open)
@@ -1759,8 +1758,6 @@ il4965_post_associate(struct il_priv *il)
=20
 	il_scan_cancel_timeout(il, 200);
=20
-	conf =3D &il->hw->conf;
