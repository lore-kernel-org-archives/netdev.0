From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCHv7 0/5 + 3] Interface group patches
Date: Thu, 29 Nov 2007 17:39:28 +0100
Message-ID: <474EEB40.7090507@balabit.hu>
References: <11963527094077-git-send-email-panther@balabit.hu> <474EE7F7.5000108@trash.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:41689 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758246AbXK2Qjb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:39:31 -0500
In-Reply-To: <474EE7F7.5000108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy =EDrta:
> Laszlo Attila Toth wrote:
>> Hello,
>>
>> This is the 7th version of our interface group patches.
>=20
>=20
>> Patches:
>>  [1/5] Remove unnecessary locks from rtnetlink (in do_setlink)
>>  [2/5] rtnetlink: send a single notification on device state changes
>>  [3/5] Interface group: core (netlink) part
>>  [4/5] Ifgroup read/write support in sysfs
>=20
> I vote for these to go in, they're ready and there's no use in
> reposting them again and again.

I see, sorry.

In fact, I didn't missed it. But you said the removing of the locks in=20
the rtnl needs a separate patch. This is why I resent _all_.


>>  [iptables]Interface group match
>=20
> This one I would queue until we have released the 1.4.0 version
> of iptables. I don't want to release things that are not in
> at least a -rc kernel yet.

Later I'll resend it in two patches, one for extending iptables with=20
hash tables and one for the ifgroup match.

>=20
>>  [iproute2 1/2] Added IFLA_NET_NS_PID as in kernel v2.6.24-rc1
>>  [iproute2 2/2] Interface group as new ip link option
>=20
> And for these Stephen has to decide, but both look fine to me.
>=20
>=20


--=20
Attila
