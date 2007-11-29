From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv6 iptables]Interface group match
Date: Thu, 29 Nov 2007 17:27:26 +0100
Message-ID: <474EE86E.2010201@trash.net>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu> <11955644702451-git-send-email-panther@balabit.hu> <11955644701536-git-send-email-panther@balabit.hu> <11955644702194-git-send-email-panther@balabit.hu> <20071123133933.GA31396@innominate.com> <474EB585.30407@balabit.hu> <474EE5C6.9070500@trash.net> <474EE79F.2000409@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lutz Jaenicke <ljaenicke@innominate.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50053 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760539AbXK2Q1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 11:27:33 -0500
In-Reply-To: <474EE79F.2000409@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Patrick McHardy =EDrta:
>> Laszlo Attila Toth wrote:
>>> Lutz Jaenicke =EDrta:

>>>> Should iptables be allowed to read "/etc/iproute2/rt_ifgroup"?
>>>
>>> It would be good but cannot be used if a mask is set and only value=
s=20
>>> less than 256 can be used with names.
>>
>>
>> Why 256? I can see no such limitation. For masks you could
>> simply allow to define masks in rt_ifgroup too and use
>> name/name or simply name/0xmask.
>=20
>=20
> 256 because it is the size of a static array (and I don't want alloca=
te=20
> too much memory when other arrays such as the routing table names als=
o=20
> have this size). In the current version I posted some minutes ago=20
> 0..2^32-1  can be used.

Its a hash. You can put as much in there as you like :)

> The syntax "name/0xmask" is simply too strange for me.

Then how about name/name with masks also defined in rt_ifgroup?
The same question applies for marks of course.

>>>> There is no standard API like getservbyname()...
>>>
>>> The code of iproute2 should be copied. If Patrick says it is ok, =20
>>> I'll write this part.
>>
>>
>> Of course. Please put the tab part somewhere common, I always
>> wanted to have named firewall marks shared with ip and tc
>> and I believe Balazs wanted that too :)
>=20
> Ok. Yes, he wants :)
>=20
>=20

