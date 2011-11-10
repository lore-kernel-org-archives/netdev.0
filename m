From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4942 recommendation
Date: Thu, 10 Nov 2011 07:23:22 -0800 (PST)
Message-ID: <1320938602.20312.YahooMailNeo@web126017.mail.ne1.yahoo.com>
References: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>   <1320423860.16609.4.camel@edumazet-laptop>   <1320482392.98040.YahooMailNeo@web126003.mail.ne1.yahoo.com>  <1320485406.16908.4.camel@edumazet-laptop>  <1320922725.65072.YahooMailNeo@web126002.mail.ne1.yahoo.com> <1320924445.2310.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1320929648.97649.YahooMailNeo@web126007.mail.ne1.yahoo.com>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm28-vm1.bullet.mail.ne1.yahoo.com ([98.138.91.35]:45791 "HELO
	nm28-vm1.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S935154Ab1KJPXX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 10:23:23 -0500
In-Reply-To: <1320929648.97649.YahooMailNeo@web126007.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----

> From: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
> To: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> Sent: Thursday, November 10, 2011 1:54 PM
> Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4=
942 recommendation
>=20
> ----- Original Message -----
>>  From: Eric Dumazet <eric.dumazet@gmail.com>
>>  To: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
>>  Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
>>  Sent: Thursday, November 10, 2011 12:27 PM
>>  Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC=
=20
> 4942 recommendation
>>=20
>>  Le jeudi 10 novembre 2011 =E0 02:58 -0800, Fran=E7ois-Xavier Le Bai=
l a
>>  =E9crit :
>>> =A0 ----- Original Message -----
>>>=20
>>> =A0 > From: Eric Dumazet <eric.dumazet@gmail.com>
>>> =A0 > To: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
>>> =A0 > Cc: "netdev@vger.kernel.org"=20
> <netdev@vger.kernel.org>
>>> =A0 > Sent: Saturday, November 5, 2011 10:30 AM
>>> =A0 > Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow=20
> the=20
>>  RFC 4942 recommendation
>>> =A0 >=20
>>> =A0 > Le samedi 05 novembre 2011 =E0 01:39 -0700, Fran=E7ois-Xavier=
 Le Bail=20
> a
>>> =A0 > =E9crit :
>>> =A0 >=20
>>> =A0 >>=20
>>> =A0 >>=A0 I will study and test these options for my application=20
> server
>>> =A0 >=20
>>> =A0 > Here is a sample of use of the IPv4 part, an udpecho service =
that=20
> use
>>> =A0 > IP_PKTINFO and IP_RECVTOS/IP_TOS to be able to use multihomed=
=20
> machine,
>>> =A0 > and reflect TOS field as well.
>>> =A0 > [. . .]
>>>=20
>>> =A0 Hi,
>>>=20
>>> =A0 I have updated the code for IPv6.
>>>=20
>>> =A0 When a UDP client send to an unicast address on a multihomed Li=
nux=20
> 3.0.0=20
>>  host, from another host, it's OK.
>>> =A0 For example :
>>> =A0 setup 2001::1 on eth0, 2a01::1 on eth1.
>>> =A0 send to 2001::1, recv from 2001::1.
>>> =A0 send to 2a01::1, recv from 2a01::1.
>>>=20
>>> =A0 When the UDP client send to an Subnet-Router anycast address on=
 a=20
>>  multihomed Linux 3.0.0 host, from another host, it's KO.
>>> =A0 send to 2001:: or 2a01::, the udpecho server display "sendmsg:=20
> Invalid=20
>>  argument".
>>>=20
>>> =A0 Any idea ?
>>=20
>>  Could you describe the setup of this machine ?
>>=20
>>  ip -6 addr
>>  ip -6 ro
>=20
> The server has ipv6 forwarding on.
>=20
> # ip -6 a
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436=20
> =A0=A0=A0 inet6 ::1/128 scope host=20
> =A0=A0=A0=A0=A0=A0 valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
> =A0=A0=A0 inet6 2a01::1/64 scope global=20
> =A0=A0=A0=A0=A0=A0 valid_lft forever preferred_lft forever
> =A0=A0=A0 inet6 fe80::20c:29ff:fecc:bc43/64 scope link=20
> =A0=A0=A0=A0=A0=A0 valid_lft forever preferred_lft forever
> 3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
> =A0=A0=A0 inet6 2001::1/64 scope global=20
> =A0=A0=A0=A0=A0=A0 valid_lft forever preferred_lft forever
> =A0=A0=A0 inet6 fe80::20c:29ff:fecc:bc4d/64 scope link=20
> =A0=A0=A0=A0=A0=A0 valid_lft forever preferred_lft forever
>=20
> # ip -6 r
> 2001::/64 dev eth1=A0 proto kernel=A0 metric 256=20
> 2a01::/64 dev eth0=A0 proto kernel=A0 metric 256=20
> fe80::/64 dev eth1=A0 proto kernel=A0 metric 256=20
> fe80::/64 dev eth0=A0 proto kernel=A0 metric 256=20
> default via 2001::2 dev eth1=A0 metric 1024=20
>=20
> 2001::2 is the address of the other (client) host.

I put a printk in addrconf.c at the beginning of ipv6_get_saddr_eval fu=
nction.
In th OK case : nothing is print.
In the KO case : many printk messages.

Any problem in RFC 3484 code ?

Thanks,
=46rancois-Xavier
