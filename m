From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
Subject: Re: RTL-8110SC lockup with r8169
Date: Fri, 07 May 2010 16:51:58 +0100
Message-ID: <4BE4371E.2010503@draigBrady.com>
References: <4BE1973D.8080502@draigBrady.com> <20100506202055.GB3541@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Glen Gray <glen@lincor.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.slb.deg.dub.stisp.net ([84.203.253.98]:4501 "HELO
	mail1.slb.deg.dub.stisp.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755348Ab0EGPxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 11:53:19 -0400
In-Reply-To: <20100506202055.GB3541@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/10 21:20, Francois Romieu wrote:
> P=C3=A1draig Brady <P@draigBrady.com> :
> [...]
>> However the above code wasn't in the 2.6.32.10-90.fc12 driver we use=
d.
>> Also I've back-ported the latest r8169 driver from git to our kernel
>> and it still has the same issue.
>=20
> "latest" as "includes 908ba2bfd22253f26fa910cd855e4ccffb1467d0" ?

Yes that was included in my driver.

> Otherwise you may save some time and try directly the backport at :
> http://userweb.kernel.org/~romieu/r8169/2.6.32.11-99.fc12/

That's handy for the future thanks!
userweb is non responsive ATM

>=20
>> # dmesg | grep 8169
>> # lspci -n | grep -v 8086:
>> 01:04.0 0200: 10ec:8167 (rev 10)
>=20
> 8167 how comes...

Dont' know. Is that significant?

>=20
> Which hardware (lspci) is the host computer made of ?

All intel bits n bobs

00:00.0 Host bridge: Intel Corporation 82852/82855 GM/GME/PM/GMV Proces=
sor to I/O Controller (rev 02)
00:00.1 System peripheral: Intel Corporation 82852/82855 GM/GME/PM/GMV =
Processor to I/O Controller (rev 02)
00:00.3 System peripheral: Intel Corporation 82852/82855 GM/GME/PM/GMV =
Processor to I/O Controller (rev 02)
00:02.0 VGA compatible controller: Intel Corporation 82852/855GM Integr=
ated Graphics Device (rev 02)
00:02.1 Display controller: Intel Corporation 82852/855GM Integrated Gr=
aphics Device (rev 02)
00:1d.0 USB Controller: Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/=
ICH4-M) USB UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/=
ICH4-M) USB UHCI Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/=
ICH4-M) USB UHCI Controller #3 (rev 02)
00:1d.7 USB Controller: Intel Corporation 82801DB/DBM (ICH4/ICH4-M) USB=
2 EHCI Controller (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 82)
00:1f.0 ISA bridge: Intel Corporation 82801DB/DBL (ICH4/ICH4-L) LPC Int=
erface Bridge (rev 02)
00:1f.1 IDE interface: Intel Corporation 82801DB (ICH4) IDE Controller =
(rev 02)
00:1f.3 SMBus: Intel Corporation 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) S=
MBus Controller (rev 02)
00:1f.5 Multimedia audio controller: Intel Corporation 82801DB/DBL/DBM =
(ICH4/ICH4-L/ICH4-M) AC'97 Audio Controller (rev 02)
01:04.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC=
/8169SC Gigabit Ethernet (rev 10)

cheers,
P=C3=A1draig.
