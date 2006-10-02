From: chunkeey@web.de
Subject: [PATCH] wext
Date: Mon, 2 Oct 2006 19:55:22 +0200
Message-ID: <200610021955.23112.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_LKVIFiR5P0fxTxG"
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:44008 "EHLO
	fmmailgate01.web.de") by vger.kernel.org with ESMTP id S965191AbWJBRzZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 13:55:25 -0400
Received: from smtp08.web.de (fmsmtp08.dlan.cinetic.de [172.20.5.216])
	by fmmailgate01.web.de (Postfix) with ESMTP id 42F5B245FCE1
	for <netdev@vger.kernel.org>; Mon,  2 Oct 2006 19:55:24 +0200 (CEST)
Received: from [84.157.243.57] (helo=debian64.daheim)
	by smtp08.web.de with asmtp (TLSv1:AES256-SHA:256)
	(WEB.DE 4.107 #114)
	id 1GUS0i-000598-00
	for netdev@vger.kernel.org; Mon, 02 Oct 2006 19:55:24 +0200
Received: from localhost.localdomain
	([127.0.0.1] helo=localhost ident=chuck)
	by debian64.daheim with esmtpa (Exim 4.63)
	(envelope-from <chunkeey@web.de>)
	id 1GUS0h-0002QZ-Ei
	for netdev@vger.kernel.org; Mon, 02 Oct 2006 19:55:23 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_LKVIFiR5P0fxTxG
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

This patch (wext-patch) is a proposal. It adds two new defines for the=20
SIOCSIWMLME to cover all kinds MLMEs (well, except REASSOC) through a ioctl.
(it would be nice to have them, so that I can post the hostapd code for the=
=20
prism54 card!)

I didn't update the changelog! but this should be done in a matter of secon=
ds.

diffstat wext-patch
=A0wireless.h | =A0 =A02 ++
=A01 file changed, 2 insertions(+)

Signed-off-by: Christian Lamparter <chunkeey@web.de>

Regards,
=A0=A0=A0=A0=A0=A0=A0=A0Chr. Lamparter

--Boundary-00=_LKVIFiR5P0fxTxG
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="wext-patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="wext-patch"

--- a/include/linux/wireless.h	2006-10-01 03:24:01.000000000 +0200
+++ b/include/linux/wireless.h	2006-10-01 03:24:38.000000000 +0200
@@ -546,6 +546,8 @@
 /* MLME requests (SIOCSIWMLME / struct iw_mlme) */
 #define IW_MLME_DEAUTH		0
 #define IW_MLME_DISASSOC	1
+#define IW_MLME_AUTH		2
+#define IW_MLME_ASSOC		3
 
 /* SIOCSIWAUTH/SIOCGIWAUTH struct iw_param flags */
 #define IW_AUTH_INDEX		0x0FFF

--Boundary-00=_LKVIFiR5P0fxTxG--
