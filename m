From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 13:39:54 +0100
Message-ID: <1324471194.2728.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EF1B0D9.2010007@monstr.eu>
			 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
			 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
			 <4EF1B5BC.5020103@monstr.eu>
			 <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
			 <4EF1B7E4.4010602@monstr.eu>
			 <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		 <1324465386.2728.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		 <4EF1BEA4.7080005@monstr.eu>
	 <1324466023.2728.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1C80B.4060701@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:34103 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481Ab1LUMj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 07:39:57 -0500
Received: by vcbfk14 with SMTP id fk14so5695334vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 04:39:57 -0800 (PST)
In-Reply-To: <4EF1C80B.4060701@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 12:50 +0100, Michal Simek a =C3=
=A9crit :

> > #define SOCK_MIN_RCVBUF (16384 + sizeof(struct sk_buff))
> >=20
>=20
> Doesn't work. :-(
>=20

Sorry, I have no idea where packet is dropped, I dont know your
application.

You might send "netstat -s" output if you cant find it ...

You spoke of ICMP message, I cant find a limit in this area ?
