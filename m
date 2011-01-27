From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Thu, 27 Jan 2011 16:05:43 +0530
Message-ID: <AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com>
References: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com>
	<AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>
	<20110116192017.GA3569@electric-eye.fr.zoreil.com>
	<AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com>
	<AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>
	<20110118012146.GA3704@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61042 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846Ab1A0Kfp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 05:35:45 -0500
Received: by bwz15 with SMTP id 15so2057053bwz.19
        for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 02:35:44 -0800 (PST)
In-Reply-To: <20110118012146.GA3704@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,
We upgraded to 2.6.36 kernel . The result is SAME.
The VLAN tag gets stripped ;-)
Do let me know if you need more info .
Thanks,
Anand


On Tue, Jan 18, 2011 at 6:51 AM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> Anand Raj Manickam <anandrm@gmail.com> :
>> On Mon, Jan 17, 2011 at 11:52 AM, Anand Raj Manickam <anandrm@gmail.=
com> wrote:
> [...]
>> > This is the dmesg =A0for XID
>> >
>> > eth0: RTL8168c/8111c at 0xf9628000, 00:17:54:00:f6:62, XID 1c4000c=
0 IRQ 31
>> > r8169: mac_version =3D 0x16
>
> I do not have one of those (RTL_GIGA_MAC_VER_22) to check if it handl=
es vlan
> correctly yet.
>
>> > r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>> >
>> > Unfortunately , i m not able to upgrade my kernel now . If there i=
s a
>> > Fix for it , that would be great !!
>
> I doubt there is a lot of glamour/fortune/fame in backporting the 89 =
r8169
> patches between v2.6.30 and v2.6.37 but you may help yourself and giv=
e it
> a try.
>
> --
> Ueimor
>
