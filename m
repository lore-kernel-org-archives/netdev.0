From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc match MAC destination
Date: Wed, 15 Jun 2011 11:43:28 +0200
Message-ID: <1308131008.9302.6.camel@edumazet-laptop>
References: <1308125523.30324.64.camel@ierdnac-hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, pdoru.kernel@evox.ro,
	netdev@vger.kernel.org
To: ierdnah@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308125523.30324.64.camel@ierdnac-hp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 15 juin 2011 =C3=A0 11:12 +0300, Andrei Popa a =C3=A9crit :
> Hello,
>=20
> I want to shape PVSTP+ traffic (traffic that has MAC destination
> 01:00:0c:cc:cc:cd) and it doesn't work.
> I've tried
> filter parent 1: protocol 802_3 pref 2 u32 fh 802::11 order 17 key ht
> 802 bkt 0 flowid 1:3=20
>   match 01000ccc/ffffffff at 0
> but it doesn't work.
>=20
> With
> filter parent 1: protocol arp pref 1 u32=20
> filter parent 1: protocol arp pref 1 u32 fh 801: ht divisor 1=20
> filter parent 1: protocol arp pref 1 u32 fh 801::7 order 7 key ht 801
> bkt 0 flowid 1:3=20
>   match 00000000/00000000 at 0
> filter parent 1: protocol 802_3 pref 2 u32=20
> filter parent 1: protocol 802_3 pref 2 u32 fh 802: ht divisor 1=20
> filter parent 1: protocol 802_3 pref 2 u32 fh 802::3 order 3 key ht 8=
02
> bkt 0 flowid 1:3=20
>   match 00000000/00000000 at 0
>         action order 1: mirred (Egress Mirror to device ifb1) pipe
>         index 1923 ref 1 bind 1
>=20
> I see arp trafic with tcpdump on ifb1, but no STP traffic or any kind=
 of
> traffic except arp, because I've matched all MAC addreses.
> Can somebody verify that this match works ?
>=20
> I use kernel 2.6.39.1.
>=20
> Thank you,

Hi Andrei

Since you refer to a very complex network setup, it would really help i=
f
you provide a self contained script so that we can take a look.

We netdev guys saw your first mail days ago but are a bit busy, so the
7th point listed in "REPORTING-BUGS" would be nice :

[7.] A small shell script or example program which triggers the problem
