From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 20:41:06 +0200
Message-ID: <1307731266.2872.4.camel@edumazet-laptop>
References: <4DF0E638.2010506@uth.tmc.edu>
	 <1307714177.4044.4.camel@edumazet-laptop> <4DF233CE.5020000@uth.tmc.edu>
	 <4DF24154.3060505@uth.tmc.edu> <1307722621.4044.17.camel@edumazet-laptop>
	 <4DF248C5.9050004@uth.tmc.edu> <1307724870.4044.20.camel@edumazet-laptop>
	 <4DF25BA2.4040200@uth.tmc.edu> <1307729054.2872.0.camel@edumazet-laptop>
	 <4DF25EE2.6020803@uth.tmc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34064 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757770Ab1FJSlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 14:41:11 -0400
Received: by wwa36 with SMTP id 36so3068517wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 11:41:10 -0700 (PDT)
In-Reply-To: <4DF25EE2.6020803@uth.tmc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 juin 2011 =C3=A0 13:13 -0500, Charles Bearden a =C3=A9cr=
it :
> On 06/10/2011 01:04 PM, Eric Dumazet wrote:
> > Le vendredi 10 juin 2011 =C3=A0 13:00 -0500, Charles Bearden a =C3=A9=
crit :
> >
> >> Each keepalive from the Win2008 machine has a 1-byte payload 0x00.=
 The last byte
> >> of the last packet with a payload before that from the Win2008 hos=
t (at
> >> 14:40:18.166394 in the paste) is also 0x00. Is that what you were =
asking about?
> >>
> >
> > Yes, thats fine, thanks :)
>=20
> One other thing: when tcp timestamps are disabled on the Linux (recei=
ving) end,=20
> so that the Win2008 host sends keepalives without timestamps, the che=
cksums in=20
> the keepalives are correct. It's only when the keepalives also contai=
n=20
> timestamps that the checksums are broken.
>=20
> If you think this might be a Linux kernel issue, I'll be glad to keep=
 working=20
> with you, but I don't want to spam this list if my problem isn't rele=
vant. Thank=20
> you for your help in any case.
>=20

Well, if your linux machine receives frames with a bad checksum, linux
is working well : These frames must be dropped.

It is a bug in the sender (Win2008 in this case).=20

I am not that surprised, given timestamps were disabled in microsoft
products until very last releases (Windows Seven, and apparently
winserver 2008)



