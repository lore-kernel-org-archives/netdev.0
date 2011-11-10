From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4942
 recommendation
Date: Thu, 10 Nov 2011 12:27:25 +0100
Message-ID: <1320924445.2310.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>
	  <1320423860.16609.4.camel@edumazet-laptop>
	  <1320482392.98040.YahooMailNeo@web126003.mail.ne1.yahoo.com>
	 <1320485406.16908.4.camel@edumazet-laptop>
	 <1320922725.65072.YahooMailNeo@web126002.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Fran=E7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:43424 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab1KJL13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 06:27:29 -0500
Received: by ywf7 with SMTP id 7so2826329ywf.19
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2011 03:27:28 -0800 (PST)
In-Reply-To: <1320922725.65072.YahooMailNeo@web126002.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 novembre 2011 =C3=A0 02:58 -0800, Fran=C3=A7ois-Xavier Le B=
ail a
=C3=A9crit :
> ----- Original Message -----
>=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > To: Fran=C3=A7ois-Xavier Le Bail <fx.lebail@yahoo.com>
> > Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> > Sent: Saturday, November 5, 2011 10:30 AM
> > Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC=
 4942 recommendation
> >=20
> > Le samedi 05 novembre 2011 =C3=A0 01:39 -0700, Fran=C3=A7ois-Xavier=
 Le Bail a
> > =C3=A9crit :
> >=20
> >>=20
> >>  I will study and test these options for my application server
> >=20
> > Here is a sample of use of the IPv4 part, an udpecho service that u=
se
> > IP_PKTINFO and IP_RECVTOS/IP_TOS to be able to use multihomed machi=
ne,
> > and reflect TOS field as well.
> > [. . .]
>=20
> Hi,
>=20
> I have updated the code for IPv6.
>=20
> When a UDP client send to an unicast address on a multihomed Linux 3.=
0.0 host, from another host, it's OK.
> For example :
> setup 2001::1 on eth0, 2a01::1 on eth1.
> send to 2001::1, recv from 2001::1.
> send to 2a01::1, recv from 2a01::1.
>=20
> When the UDP client send to an Subnet-Router anycast address on a mul=
tihomed Linux 3.0.0 host, from another host, it's KO.
> send to 2001:: or 2a01::, the udpecho server display "sendmsg: Invali=
d argument".
>=20
> Any idea ?

Could you describe the setup of this machine ?

ip -6 addr
ip -6 ro

=2E..
