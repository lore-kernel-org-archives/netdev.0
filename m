From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Thu, 02 Feb 2012 10:12:52 +0100
Message-ID: <1328173972.2279.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	 <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	 <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	 <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	 <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
	 <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
	 <4F2991FD.8090407@ziu.info>
	 <1328173741.73927.YahooMailNeo@web29018.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Soltys <soltys@ziu.info>,
	yao zhao <yao.development@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:45757 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab2BBJM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 04:12:56 -0500
Received: by wics10 with SMTP id s10so1568417wic.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 01:12:55 -0800 (PST)
In-Reply-To: <1328173741.73927.YahooMailNeo@web29018.mail.ird.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 09:09 +0000, Leonardo Uzcudun a =C3=
=A9crit :
> Hello Michal:
>=20
> It is working on kernel 3.0.0-15 Ubuntu. I've just to modify the
> ebtables command as:
> ebtables -t broute -A BROUTING -i eth0 -p 802_1Q --vlan-id 101 -j DRO=
P
> (protocol is a must when you use --vlan-id)
>=20
>=20
> I'll test it on kernel 2.6.32-5 Debian
>=20
>=20
> Just last question,in the case i should implement this kind of
> configuration in a kernel 2.6.31, should i backport/patch anything? i=
s
> it a bad idea (running it on 2.6.31)?

This is going to be tough.=20

The point of Jesse Gross (and others) work was exactly to permit better
vlan/bridge integration/stacking.

I am not saying you cant do it. If you really have time you certainly
can.
