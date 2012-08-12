From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net 0/3] qmi_wwan: simplify device matching and add a few new devices
Date: Sun, 12 Aug 2012 21:16:29 +0200
Message-ID: <1344798992-10176-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The home cooked whitelisting code can be removed now that=20
the USB core supports interface number matching.

The second patch adds a few new devices.

The third patch improves device list readability by using
existing macros where possible.

I hope this can go in 3.6-rc2/3. The series is based on
the current net/master (commit 2359a476)


Bj=C3=B8rn Mork (3):
  net: qmi_wwan: use fixed interface number matching
  net: qmi_wwan: add Sierra Wireless devices
  net: qmi_wwan: compress device_id list using macros

 drivers/net/usb/qmi_wwan.c |  248 +++++++-----------------------------=
--------
 1 file changed, 40 insertions(+), 208 deletions(-)

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
