From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: New ASIX USB3 product
Date: Tue, 20 Nov 2012 09:15:23 +0100
Message-ID: <50AB3C1B.7030402@omicron.at>
References: <CALJXSJp+m7FewpW2i6wJoFAN0oGwao4-KjWuUX0F_dcE5vsoPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?SsOpcsO0bWUgUG91bGlu?= <jeromepoulin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46964 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444Ab2KTIQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 03:16:24 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so2246689bkw.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 00:16:23 -0800 (PST)
In-Reply-To: <CALJXSJp+m7FewpW2i6wJoFAN0oGwao4-KjWuUX0F_dcE5vsoPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

J=C3=A9r=C3=B4me,

On 2012-11-19 20:02, J=C3=A9r=C3=B4me Poulin wrote:
> I just bought a gigabit ethernet USB3 adapter, it is a StarTech
> USB31000S adapter and it does not seem to be un ASIX product database
> yet.

The AX88179 device is not yet supported by the mainline asix drivers.=20
You could try to use the driver from the ASIX website [1]. Or you could=
=20
compare this driver to the code in drivers/net/usb/a* and see if one of=
=20
these drivers would work for the AX88179 and add an entry for the=20
AX88179 in usb_device_id struct in asix_devices.c.

Regards, Christian

[1]=20
http://www.asix.com.tw/products.php?op=3DpItemdetail&PItemID=3D131;71;1=
12&PLine=3D71
