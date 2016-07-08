From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: bcmgenet: use
 phy_ethtool_{get|set}_link_ksettings
Date: Thu, 7 Jul 2016 18:29:40 -0700
Message-ID: <577F0204.9070601@gmail.com>
References: <1467560037-21784-1-git-send-email-tremyfr@gmail.com>
 <1467560037-21784-2-git-send-email-tremyfr@gmail.com>
 <20160704.160300.953705748553101659.davem@davemloft.net>
 <577B37CC.80807@gmail.com> <577C2189.8090604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33218 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbcGHB3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 21:29:44 -0400
In-Reply-To: <577C2189.8090604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2016 02:07 PM, Philippe Reynes wrote:
> Hi Florian,
>=20
> On 05/07/16 06:30, Florian Fainelli wrote:
>> Le 04/07/2016 16:03, David Miller a =C3=A9crit :
>>> From: Philippe Reynes<tremyfr@gmail.com>
>>> Date: Sun,  3 Jul 2016 17:33:57 +0200
>>>
>>>> There are two generics functions phy_ethtool_{get|set}_link_ksetti=
ngs,
>>>> so we can use them instead of defining the same code in the driver=
=2E
>>>>
>>>> Signed-off-by: Philippe Reynes<tremyfr@gmail.com>
>>>
>>> Applied.
>>>
>>
>> The transformation is not equivalent, we lost the checks on
>> netif_running() in the process, and those are here for a reason, if =
the
>> interface is down and therefore clock gated, MDIO accesses to the PH=
Y
>> will simply fail outright and cause bus errors.
>=20
> Oh, I see, I've missed this. Sorry for this mistake.
> We should revert this path.

Can you send such a revert please? Thanks!
--=20
=46lorian
