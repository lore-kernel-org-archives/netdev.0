From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/7] bfin_mac: fix build error due to
	net_device_ops convert
Date: Tue, 26 May 2009 19:14:16 -0400
Message-ID: <8bd0f97a0905261614m269013ay9c800aa3060df387@mail.gmail.com>
References: <1243330149-15300-1-git-send-email-vapier@gentoo.org>
	 <20090526.022927.34737131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, a.beregalov@gmail.com,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:33298 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083AbZEZXOP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 19:14:15 -0400
Received: by gxk10 with SMTP id 10so7163753gxk.13
        for <netdev@vger.kernel.org>; Tue, 26 May 2009 16:14:16 -0700 (PDT)
In-Reply-To: <20090526.022927.34737131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2009 at 05:29, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
> Date: Tue, 26 May 2009 05:29:09 -0400
>
>> The previous commit "convert to net_device_ops" broke the Blackfin M=
AC
>> driver as it declared the new structure before the function it used:
>> =C2=A0 CC =C2=A0 =C2=A0 =C2=A0drivers/net/bfin_mac.o
>> drivers/net/bfin_mac.c:984: error: =E2=80=98bfin_mac_close=E2=80=99 =
undeclared here (not in a function)
>> make[1]: *** [drivers/net/bfin_mac.o] Error 1
>>
>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>
> I'll queue this up, thank you.

for 2.6.30 right ? :)  this is a fix for an error introduced during
the 2.6.30 merge window ...
-mike
