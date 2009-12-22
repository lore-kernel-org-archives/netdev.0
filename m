From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH] wireless: adf702x: new driver for
	ADF7020/21 parts
Date: Tue, 22 Dec 2009 08:09:43 -0500
Message-ID: <8bd0f97a0912220509w641a4e2cv615bc6d690cabab0@mail.gmail.com>
References: <1261447929-17106-1-git-send-email-vapier@gentoo.org>
	<1261451102.4041.170.camel@localhost.localdomain> <8A42379416420646B9BFAC9682273B6D0EF11EC1@limkexm3.ad.analog.com>
	<1261486016.609.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Hennerich, Michael" <Michael.Hennerich@analog.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:64677 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbZLVNKE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 08:10:04 -0500
Received: by yxe17 with SMTP id 17so5804122yxe.33
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2009 05:10:03 -0800 (PST)
In-Reply-To: <1261486016.609.4.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2009 at 07:46, Marcel Holtmann wrote:
>> >> =C2=A0drivers/net/wireless/Kconfig =C2=A0 | =C2=A0 11 +
>> >> =C2=A0drivers/net/wireless/Makefile =C2=A0| =C2=A0 =C2=A02 +
>> >> =C2=A0drivers/net/wireless/adf702x.c | =C2=A0788
>> >> =C2=A0include/linux/spi/adf702x.h =C2=A0 =C2=A0| =C2=A0 33 ++
>> >> =C2=A04 files changed, 834 insertions(+), 0 deletions(-)
>> >> =C2=A0create mode 100644 drivers/net/wireless/adf702x.c
>> >> =C2=A0create mode 100644 include/linux/spi/adf702x.h
>> >
>> >And why is the header file under SPI includes. It could be as easil=
y in
>> >the same directory as the driver *.c file itself. No reason to spre=
ad it
>> >over the whole tree if nothing else includes it.
>>
>> It under include/linux/spi/ because it includes platform data which =
is used by board support files.
>
> that is no argument to move it there. It is a driver specific header =
and
> so keep it in the same location as the driver itself.

that is incorrect.  for devices that need platform resources, the
structure is in a header in the include/ tree.  it cannot be in
drivers/net/ where boards are unable to include it.

whether it goes in linux/spi/ or linux/net/ or somewhere else we dont
really care.  linux/spi/ seems to be the best match so far.
-mike
