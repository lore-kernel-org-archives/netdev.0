From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 20:44:50 +0200
Message-ID: <1304793890.3207.28.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
	 <1304785589.3207.5.camel@edumazet-laptop>
	 <472A3314CA89E2E5270E320A@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35574 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418Ab1EGSox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 14:44:53 -0400
Received: by wya21 with SMTP id 21so3071950wya.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 11:44:52 -0700 (PDT)
In-Reply-To: <472A3314CA89E2E5270E320A@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 19:38 +0100, Alex Bligh a =C3=A9crit :
>=20
> --On 7 May 2011 18:26:29 +0200 Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>=20
> ># time rmmod dummy
> >
> > real	0m0.111s
> > user	0m0.000s
> > sys	0m0.000s
> >
> >
> > This removed my two dummy0/dummy1 devices.
>=20
> rmmod dummy even with numdummies=3D100 does only one synchronize_net(=
) and
> is quick (0.8ms).
>=20

Yes, thanks to batching we added some time ago to speedup module unload=
=2E

And because you didnt setup IP addresses on them ;)

for i in `seq 0 99`
do
ifconfig dummy$i 192.168.$i.1 up
done



