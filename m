From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv6 iptables]Interface group match
Date: Thu, 29 Nov 2007 17:16:06 +0100
Message-ID: <474EE5C6.9070500@trash.net>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu> <11955644702451-git-send-email-panther@balabit.hu> <11955644701536-git-send-email-panther@balabit.hu> <11955644702194-git-send-email-panther@balabit.hu> <20071123133933.GA31396@innominate.com> <474EB585.30407@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lutz Jaenicke <ljaenicke@innominate.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49721 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762298AbXK2QQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 11:16:12 -0500
In-Reply-To: <474EB585.30407@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Lutz Jaenicke =EDrta:
>> On Tue, Nov 20, 2007 at 02:14:28PM +0100, Laszlo Attila Toth wrote:
>>> Interface group values can be checked on both input and output=20
>>> interfaces
>>> with optional mask.
>>
>>> Index: extensions/libxt_ifgroup.c
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> --- extensions/libxt_ifgroup.c    (revision 0)
>>> +++ extensions/libxt_ifgroup.c    (revision 0)
>>
>>> +        info->in_group =3D strtoul(optarg, &end, 0);
>>
>> This is somewhat inconsistent with the iproute patch which targets
>> specific groups (with names).
>> Should iptables be allowed to read "/etc/iproute2/rt_ifgroup"?
>=20
> It would be good but cannot be used if a mask is set and only values=20
> less than 256 can be used with names.


Why 256? I can see no such limitation. For masks you could
simply allow to define masks in rt_ifgroup too and use
name/name or simply name/0xmask.

>> There is no standard API like getservbyname()...
>=20
> The code of iproute2 should be copied. If Patrick says it is ok,  I'l=
l=20
> write this part.


Of course. Please put the tab part somewhere common, I always
wanted to have named firewall marks shared with ip and tc
and I believe Balazs wanted that too :)

