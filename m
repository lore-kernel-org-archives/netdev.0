From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Some question about 802.1Q VLAN
Date: Thu, 12 Feb 2015 05:40:35 -0800
Message-ID: <20150212054035.7c7f6ff1@uryu.home.lan>
References: <79f6e3b1.10533.14b723e5dc4.Coremail.dovelijian@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?5a6J55CGIOadjuWJkQ==?= <dovelijian@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:56839 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755292AbbBLNkk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 08:40:40 -0500
Received: by mail-pa0-f53.google.com with SMTP id lf10so11450945pab.12
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 05:40:40 -0800 (PST)
In-Reply-To: <79f6e3b1.10533.14b723e5dc4.Coremail.dovelijian@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Feb 2015 14:47:44 +0800 (CST)
=E5=AE=89=E7=90=86 =E6=9D=8E=E5=89=91 <dovelijian@163.com> wrote:

>=20
>=20
>=20
>=20
> HI=E2=80=A6I am a Linux VLAN user. Now, I encounter some question abo=
ut 802.1Q VLAN in my wireless AP. My Linux kernel version is 2.6.31.
> =C2=A0
> Plese see my setting:
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 vconfig =
add eth0 10
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 vconfig =
add ath0 10
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ifconfig=
 eth0.10 up
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ifconfig=
 ath0.10 up
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 brctl ad=
dbr br0
>           brctl addbr br1
>           brctl addif br0 ath0
>           brctl addif br0 eth0
>           brctl addif br1 ath0.10
>           brctl addif br1 eth0.10
>           ifconfig br0 up
>           ifconfig br1 up
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =
=C2=A0
> The eth0 and ath0 is real network card in my AP,and the ath0 is the w=
ireless card.
> =C2=A0
> Question:
> =C2=A0=C2=A0 =C2=A0 Two station associate AP by wireless,the two stat=
ion and AP use same VLAN setting like my describe.One station br0 Ip ad=
dress is 192.168.1.10/24,br1 ip address is 192.168.2.10/24;other statio=
n br0 ip address is 192.169.1.11/24, br1 ip address is 192.168.2.12/24.=
The AP is used bridge the data from station.
> =C2=A0 But now use station1 ping station2: ping 192.168.1.11,it is su=
ccessed; ping 192.168.2.12,it is failed!!!
> =C2=A0 I don=E2=80=99t know the reason about the fail situation ,I ne=
ed some help.
> =C2=A0 Thank you!

Wireless internally is point to point and does support true promiscious
mode. Typically AP's implement Ethernet level (L2) NAT to deal with thi=
s.
=20
