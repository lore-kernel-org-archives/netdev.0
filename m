From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 00:11:46 +0800
Message-ID: <1324483906.6471.7.camel@barry.pixelworks.com>
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
	 <1324471194.2728.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1DF00.1090309@monstr.eu>
	 <1324474811.2728.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF1EC28.90008@monstr.eu>
	 <1324481439.2301.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324482285.2301.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324483302.6471.3.camel@barry.pixelworks.com>
	 <1324483543.2301.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: monstr@monstr.eu, David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:39820 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab1LUQMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 11:12:44 -0500
Received: by ghbz12 with SMTP id z12so4903639ghb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 08:12:43 -0800 (PST)
In-Reply-To: <1324483543.2301.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-21 at 17:05 +0100, Eric Dumazet wrote:
> Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 00:01 +0800, Jun Zhao a =C3=A9c=
rit :
>=20
> > Why receive buffer size MUST bigger than the jumbo frames size even=
 if
> > the packet size is small?
>=20
> Thats the way it is in linux.
>=20
> We count the memory size used by the packet.
>=20
> If not, a malicious attacker could send 1-byte frames and exhaust you=
r
> kernel memory.
>=20
> If you want to reduce it, you might use copybreak : Some drivers copy
> the data into a small skb instead of providing a jumbo frame to upper
> stack.
>=20
> tg3 for example.
>=20
>=20
>=20

Eric Dumazet:

I got it, thanks for you explanation.=20
