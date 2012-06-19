From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 4/5] net: qmi_wwan: shorten driver description
Date: Tue, 19 Jun 2012 12:42:02 +0200
Message-ID: <1340102523-23990-5-git-send-email-bjorn@mork.no>
References: <1340102523-23990-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, Dan Williams <dcbw@redhat.com>,
	linux-usb@vger.kernel.org,
	"Andrew Bird (Sphere Systems)" <ajb@spheresystems.co.uk>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43939 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752052Ab2FSKmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 06:42:32 -0400
In-Reply-To: <1340102523-23990-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The description is used in ethtool fixed length fields.  Make
it shorter to avoid truncation.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 05571fc..f12ba3c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -360,7 +360,7 @@ err:
 }
=20
 static const struct driver_info	qmi_wwan_info =3D {
-	.description	=3D "QMI speaking wwan device",
+	.description	=3D "WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind,
 	.unbind		=3D qmi_wwan_unbind,
@@ -368,7 +368,7 @@ static const struct driver_info	qmi_wwan_info =3D {
 };
=20
 static const struct driver_info	qmi_wwan_shared =3D {
-	.description	=3D "QMI speaking wwan device with combined interface",
+	.description	=3D "WWAN/QMI device",
 	.flags		=3D FLAG_WWAN,
 	.bind		=3D qmi_wwan_bind_shared,
 	.unbind		=3D qmi_wwan_unbind,
--=20
1.7.10
