From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Sat, 19 Jan 2013 13:18:39 +0100
Message-ID: <66b5bf04-09fa-433f-85d2-6e450cecab05@email.android.com>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59957 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933Ab3ASMSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 07:18:53 -0500
In-Reply-To: <1358519147-10073-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>+	for (i =3D 0; i < USB_MAXIADS; i++) {
>+		iad =3D udev->actconfig->intf_assoc[i];
>+		if (iad->bFirstInterface =3D=3D mnum && iad->bInterfaceCount =3D=3D=
 2)
>+			return usb_ifnum_to_if(udev, mnum + 1);

Ouch.  This looks buggy. Please do not apply. I will send a fixed versi=
on later.=20

Bj=C3=B8rn
