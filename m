From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Tue, 20 Apr 2010 16:03:17 +0200
Message-ID: <4BCDB425.9050007@lastsummer.de>
References: <1271452358.16881.4486.camel@edumazet-laptop>	 <1271520633.16881.4754.camel@edumazet-laptop>	 <20100419.130905.210660275.davem@davemloft.net>	 <20100419.132318.192086187.davem@davemloft.net>	 <1271709121.3845.94.camel@edumazet-laptop>	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>	 <1271743164.3845.128.camel@edumazet-laptop>	 <1271750198.3845.216.camel@edumazet-laptop>	 <4BCDA2B5.4060609@lastsummer.de> <1271769404.7895.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:59929 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754751Ab0DTOD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 10:03:27 -0400
In-Reply-To: <1271769404.7895.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 20 avril 2010 =C3=A0 14:48 +0200, Franco Fichtner a =C3=A9cr=
it :
>=20
>> I thought about this for some time...
>>
>> Do we really need the port numbers here at all? A simple
>> addr1^addr2 can provide a good enough pointer for
>> distribution amongst CPUs.
>>
>> The real connection tracking is better done locally at the
>> corresponding CPU. That way a potential cache miss can be
>> avoided and the still needed hash calculation for
>> connection tracking will be offloaded.
>>
>=20
> Yes, doing the port test/swap is useful in the loopback case=20
> (addr1 =3D=3D addr2).
>=20
> This is probably a bit convoluted, but David (and me) found this
> funny ;)
>=20
>=20

It is funny, but I fail to see the big picture of the
firewall / conntrack application here. It looks like
this is needed for local netperf tests to impress, but
it's a quite special use case, isn't it?
