From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCHv6 iptables]Interface group match
Date: Thu, 29 Nov 2007 13:50:13 +0100
Message-ID: <474EB585.30407@balabit.hu>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu> <11955644702451-git-send-email-panther@balabit.hu> <11955644701536-git-send-email-panther@balabit.hu> <11955644702194-git-send-email-panther@balabit.hu> <20071123133933.GA31396@innominate.com>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Lutz Jaenicke <ljaenicke@innominate.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20071123133933.GA31396@innominate.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lutz Jaenicke =EDrta:
> On Tue, Nov 20, 2007 at 02:14:28PM +0100, Laszlo Attila Toth wrote:
>> Interface group values can be checked on both input and output inter=
faces
>> with optional mask.
>=20
>> Index: extensions/libxt_ifgroup.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- extensions/libxt_ifgroup.c	(revision 0)
>> +++ extensions/libxt_ifgroup.c	(revision 0)
>=20
>> +		info->in_group =3D strtoul(optarg, &end, 0);
>=20
> This is somewhat inconsistent with the iproute patch which targets
> specific groups (with names).
> Should iptables be allowed to read "/etc/iproute2/rt_ifgroup"?

It would be good but cannot be used if a mask is set and only values=20
less than 256 can be used with names.

> There is no standard API like getservbyname()...

The code of iproute2 should be copied. If Patrick says it is ok,  I'll=20
write this part.

>=20
> I do have a draft patch for physdev which is however against
> iptables-1.3.8 and linux-2.6.19 so it will need some more work
> but I will attach it for discussion.

Thanks. I will send soon for net-2.6.25 and iptables svn version.

-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
