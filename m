From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Thu, 28 Apr 2016 11:54:19 -0400 (EDT)
Message-ID: <20160428.115419.1831238411921569629.davem@davemloft.net>
References: <20160427151336.GB1962@nanopsycho.orion>
	<20160427.125506.1088576804354580011.davem@davemloft.net>
	<5721FB26.6070305@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, fw@strlen.de, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbcD1PyX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 11:54:23 -0400
In-Reply-To: <5721FB26.6070305@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 28 Apr 2016 13:59:34 +0200

> Le 27/04/2016 18:55, David Miller a =E9crit :
>> From: Jiri Pirko <jiri@resnulli.us>
> [snip]
>>> The difference is that it this tries to allow userspace crap to mir=
ror
>>> setting user does for bridge/ovs. Basically this looks to me like a=
n
>>> attempt to enable userspace SDKs and such.
>>=20
>> +1
> I don't think so because a userspace can receive all the bridge/ovs s=
ettings by
> mean of netlink mirror, without the need for this driver at all.

You can say whatever you want, but the facilities you are adding to
this driver enables proprietary userland SDK components.

And this is precisely what we are trying to avoid by having a clean,
fully featured switch device model in the kernel.

It is against your interestes of upstreaming your driver to continue
denying what your changes facilitate.

THanks.
