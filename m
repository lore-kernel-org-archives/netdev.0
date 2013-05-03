From: Teppo Kotilainen <qubit303@gmail.com>
Subject: [PATCH] net: qmi_wwan: Add Telewell TW-LTE 4G
Date: Fri, 03 May 2013 12:05:13 +0300
Message-ID: <51837DC9.2070409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f66.google.com ([209.85.215.66]:46880 "EHLO
	mail-la0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab3ECJFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 05:05:21 -0400
Received: by mail-la0-f66.google.com with SMTP id fo12so467345lab.9
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 02:05:19 -0700 (PDT)
Received: from [10.170.113.82] (85-76-60-196-nat.elisa-mobile.fi. [85.76.60.196])
        by mx.google.com with ESMTPSA id rp6sm3884073lbb.7.2013.05.03.02.05.17
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 May 2013 02:05:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Information from driver description files:

  diag:  VID_19D2&PID_0412&MI_00
  nmea:  VID_19D2&PID_0412&MI_01
  at:    VID_19D2&PID_0412&MI_02
  modem: VID_19D2&PID_0412&MI_03
  net:   VID_19D2&PID_0412&MI_04

Signed-off-by: Teppo Kotilainen <qubit303@gmail.com>
Acked-by: Bj=F8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 5a88e72..834e405 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -548,6 +548,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x19d2, 0x0265, 4)},	/* ONDA MT8205 4G LTE */
 	{QMI_FIXED_INTF(0x19d2, 0x0284, 4)},	/* ZTE MF880 */
 	{QMI_FIXED_INTF(0x19d2, 0x0326, 4)},	/* ZTE MF821D */
+	{QMI_FIXED_INTF(0x19d2, 0x0412, 4)},	/* Telewell TW-LTE 4G */
 	{QMI_FIXED_INTF(0x19d2, 0x1008, 4)},	/* ZTE (Vodafone) K3570-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x1010, 4)},	/* ZTE (Vodafone) K3571-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x1012, 4)},
--=20
1.8.1.2
