From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 0/2] qmi_wwan changes intended for 3.7
Date: Fri,  7 Sep 2012 19:36:05 +0200
Message-ID: <1347039367-12399-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Just a couple of minor improvements for 3.7.  The QMI
message size issue is not considered important enough for
stable.  It does not affect the primary device function
at all, and I consider it more of a feature enhancement
than a fix.


Bj=C3=B8rn Mork (2):
  net: qmi_wwan: increase max QMI message size to 4096
  net: qmi_wwan: use a single bind function for all device types

 drivers/net/usb/qmi_wwan.c |   47 ++++++++++++++++--------------------=
--------
 1 file changed, 17 insertions(+), 30 deletions(-)

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
