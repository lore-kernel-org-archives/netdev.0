From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ifreq flags or ioctl calls to turn an interface down?
Date: Thu, 12 May 2011 15:32:23 +0200
Message-ID: <1305207143.3795.23.camel@edumazet-laptop>
References: <BANLkTim=DPqz+pS3DDHw=C4MGMJmu6t=GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chin Shi Hong <cshong87@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59005 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757075Ab1ELNc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 09:32:28 -0400
Received: by wwa36 with SMTP id 36so1767310wwa.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 06:32:27 -0700 (PDT)
In-Reply-To: <BANLkTim=DPqz+pS3DDHw=C4MGMJmu6t=GA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 mai 2011 =C3=A0 21:27 +0800, Chin Shi Hong a =C3=A9crit :
> Dear all,
>=20
> I am developing an application that will turn a network interface dow=
n
> (something like command "ifconfig <network interface> down".
>=20
> What are the ifreq flags or ioctl calls to turn a network interface d=
own?
>=20
> Or is there any other way to implement this feature into my applicati=
on?

Quick answer :

strace ifconfig eth2 down

=2E..
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) =3D 4

ioctl(4, SIOCGIFFLAGS, {ifr_name=3D"eth2", ifr_flags=3DIFF_UP|IFF_BROAD=
CAST|
IFF_RUNNING|IFF_MULTICAST}) =3D 0

ioctl(4, SIOCSIFFLAGS, {ifr_name=3D"eth2", ifr_flags=3DIFF_BROADCAST|
IFF_RUNNING|IFF_MULTICAST}) =3D 0



