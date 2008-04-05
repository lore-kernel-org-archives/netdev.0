From: Georgi Chorbadzhiyski <gf@unixsol.org>
Subject: Re: Linux 2.6.25-rc6: WARNING: at net/ipv4/tcp_input.c:2510
Date: Sat, 05 Apr 2008 14:09:25 +0300
Message-ID: <47F75DE5.4060407@unixsol.org>
References: <47EBCB75.6030600@unixsol.org> <Pine.LNX.4.64.0804031315360.21524@wrl-59.cs.helsinki.fi> <47F5C7D1.1080906@unixsol.org> <Pine.LNX.4.64.0804042209530.415@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752465AbYDELJk@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0804042209530.415@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Around 04/04/08 22:15, Ilpo J=E4rvinen scribbled:
>> The machine that gave me this error is a http and ftp server handlin=
g not
>> very busy distro mirror (if this can give you any clues).
>>
>>> processing expensive verification of TCP state (validates TCP write=
 queue=20
>>> invariants multiple times per ACK by scanning through the write que=
ue) on=20
>>> such machine?
>> How to run such a thing, can you give me some pointers?
>=20
> I sent the patch recently to netdev/lkml:
>=20
>   http://marc.info/?l=3Dlinux-netdev&m=3D120733529216457&w=3D2
>=20
> But it's very expensive in processing wise so it might not be wise to=
 put=20
> it in if performance is important for you.

Ok, I patched the kernel and will let it run for a while. Performance i=
s
an issue but I think it's better to pinpoint the bug.

--=20
Georgi Chorbadzhiyski
http://georgi.unixsol.org/
