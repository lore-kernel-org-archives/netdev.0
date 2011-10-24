From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Kernel driver r8169 not working for Realtek 8111E onboard network card
Date: Mon, 24 Oct 2011 23:10:01 +0200
Message-ID: <20111024211001.GA16830@electric-eye.fr.zoreil.com>
References: <1319296941.68390.YahooMailNeo@web161905.mail.bf1.yahoo.com> <20111022214443.GA21689@electric-eye.fr.zoreil.com> <1319482444.38178.YahooMailNeo@web161917.mail.bf1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Adrian George Sav <adi_sav@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38210 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755993Ab1JXVNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 17:13:25 -0400
Content-Disposition: inline
In-Reply-To: <1319482444.38178.YahooMailNeo@web161917.mail.bf1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian George Sav <adi_sav@yahoo.com> :
> I don't know what you mean by "current -rc", the release candidate ve=
rsion
> of the kernel or maybe of the driver ?

Recent 3.1-rc kernel. You can go with 3.1 now.

[...]
> Trying to solve this, I installed the latest version of ubuntu, becau=
se I
> saw it has a new kernel, 3.0.0.12, but no improvement.

See below.

[...]
> [=C2=A0=C2=A0=C2=A0 0.000000] Linux version 3.0.0-12-generic (buildd@=
vernadsky) (gcc version 4.6.1 (Ubuntu/Linaro 4.6.1-9ubuntu3) ) #20-Ubun=
tu SMP Fri Oct 7 14:50:42 UTC 2011 (Ubuntu 3.0.0-12.20-generic 3.0.4)
[...]
> [=C2=A0=C2=A0=C2=A0 1.893490] r8169 0000:07:00.0: eth0: RTL8168b/8111=
b at 0xf802e000, f4:6d:04:40:36:6f, XID 0c900800 IRQ 48
                                           ^^^^^^^^^^^^^^
If it was recent enough, the kernel would say "RTL8168evl/8111evl".

If you want to use jumbo frames, you will have to use David Miller's -n=
ext
branch or wait for 3.1-rc1.

--=20
Ueimor
