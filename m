From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 08:50:39 +0100
Message-ID: <476B704F.9000400@cosmosbay.com>
References: <476B65F8.10201@cosmosbay.com>	<20071221.162833.82587283.yoshfuji@linux-ipv6.org>	<476B6DAC.2030102@cosmosbay.com> <20071221.164458.51184496.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:59495 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbXLUHuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 02:50:54 -0500
In-Reply-To: <20071221.164458.51184496.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E a =C3=A9crit :
> In article <476B6DAC.2030102@cosmosbay.com> (at Fri, 21 Dec 2007 08:3=
9:24 +0100), Eric Dumazet <dada1@cosmosbay.com> says:
>=20
>>> Okay, anyway, I'll convert them to unsigned int, which is more
>>> appropriate.
>> I didnt chose this path, because David was against changing some fie=
lds from=20
>> 'int' to 'unsigned'. If you look in other parts of networking, we ha=
ve many >>=20
>> 1 or >> 2 already there.
>=20
> I do think it is safe to convert them here.
>=20

Sure :)



