From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem wit route cache
Date: Mon, 08 Feb 2010 14:28:10 +0100
Message-ID: <1265635690.3048.8.camel@edumazet-laptop>
References: <4B700EC2.5090207@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:43426 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab0BHN2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 08:28:14 -0500
Received: by bwz23 with SMTP id 23so1088446bwz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 05:28:13 -0800 (PST)
In-Reply-To: <4B700EC2.5090207@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 14:16 +0100, Pawe=C5=82 Staszewski=
 a =C3=A9crit :
> Hello
>=20
>  From some time i have problem with route cache in linux
> this is an info that i have in dmesg:
>=20
> Route hash chain too long!
> Adjust your secret_interval!
> Route hash chain too long!
> Adjust your secret_interval!
> Route hash chain too long!
> Adjust your secret_interval!
> Route hash chain too long!
> Adjust your secret_interval!
> Route hash chain too long!
> Adjust your secret_interval!
> Route hash chain too long!
> Adjust your secret_interval!
> Route hash chain too long!
> Adjust your secret_interval!
> Route hash chain too long!
> Adjust your secret_interval!
> vlan0811: 9 rebuilds is over limit, route caching disabled
> Route hash chain too long!
> Adjust your secret_interval!
>=20
> The problem is that change of  net.ipv4.route.secret_interval is chan=
ge=20
> nothing -- no matter that i set secret_interval from dfault 3600 to 2=
 or=20
> 10000 i have always the same info about route cahce is disabled.
> Also i change this parameter net.ipv4.rt_cache_rebuild_count from=20
> default 4 to 9 and the same info - i try also change this to 12 but a=
lso=20
> this change nothing.
>=20
> The machine that have this info is:
> 2x Intel(R) Xeon(R) CPU           X5450  @ 3.00GHz
> 12GB of RAM
>=20

Are you running a 64bit kernel ?
What is your kernel version ?

Please send :

# grep . /proc/sys/net/ipv4/route/*
#rtstat -c10 -i1



