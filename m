From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: fec: add netif status check before
 set mac address
Date: Wed, 09 Sep 2015 14:13:58 -0700 (PDT)
Message-ID: <20150909.141358.326274720028211993.davem@davemloft.net>
References: <1441766567-30689-1-git-send-email-b38611@freescale.com>
	<55EFA98F.7010700@gmail.com>
	<BN3PR0301MB1219283913FA957BB6943F27F5520@BN3PR0301MB1219.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: fugang.duan@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573AbbIIVOA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:14:00 -0400
In-Reply-To: <BN3PR0301MB1219283913FA957BB6943F27F5520@BN3PR0301MB1219.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Duan Andy <fugang.duan@freescale.com>
Date: Wed, 9 Sep 2015 03:45:48 +0000

> From: Florian Fainelli <f.fainelli@gmail.com> Sent: Wednesday, Septem=
ber 09, 2015 11:38 AM
>> To: Duan Fugang-B38611; davem@davemloft.net
>> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com
>> Subject: Re: [PATCH net-next 1/1] net: fec: add netif status check b=
efore
>> set mac address
>>=20
>> Le 09/08/15 19:42, Fugang Duan a =E9crit :
>> > There exist one issue by below case that case system hang:
>> > ifconfig eth0 down
>> > ifconfig eth0 hw ether 00:10:19:19:81:19
>> >
>> > After eth0 down, all fec clocks are gated off. In the
>> > .fec_set_mac_address() function, it will set new MAC address to
>> registers, which causes system hang.
>> >
>> > So it needs to add netif status check to avoid registers access wh=
en
>> > clocks are gated off. Until eth0 up the new MAC address are wrote =
into
>> related registers.
>>=20
>> Since this is a bug fix, do not you intend to target the "net" tree
>> instead of "net-next"?
>>=20
> Thanks for your reminding, it is better to enter net tree.
>=20
> David, if you apply it, pls put it into net tree. Thanks.

You need to address the feedback given by Lucas first.
