From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/5] 6lowpan: remove unecessary break
Date: Thu, 24 Oct 2013 23:42:18 -0400 (EDT)
Message-ID: <20131024.234218.106475949731790312.davem@davemloft.net>
References: <1382647904-11311-6-git-send-email-alex.aring@gmail.com>
	<EFDF4460-F8D0-4721-82F1-ABC3D5F75FDA@gmail.com>
	<1382672451.2068.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alex.bluesman.smirnov@gmail.com, alex.aring@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754310Ab3JYDmW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 23:42:22 -0400
In-Reply-To: <1382672451.2068.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>
Date: Thu, 24 Oct 2013 20:40:51 -0700

> On Fri, 2013-10-25 at 07:28 +0400, Alexander Smirnov wrote:
>> > 25 =CF=CB=D4. 2013 =C7., =D7 0:51, Alexander Aring <alex.aring@gma=
il.com> =CE=C1=D0=C9=D3=C1=CC(=C1):
> []
>> > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> []
>> > @@ -440,7 +440,6 @@ lowpan_uncompress_udp_header(struct sk_buff *s=
kb, struct udphdr *uh)
>> >        default:
>> >            pr_debug("ERROR: unknown UDP format\n");
>> >            goto err;
>> > -            break;
>> >        }
>> >=20
>>=20
>> It's not an unnecessary, it's let say a "good coding practice" to ha=
ve a break for every case including default.=20
>=20
> Hello Alexanders:
>=20
> Some would otherwise say it's a poor practice.

I think with a goto there at the end of the case statement, it's redund=
ant
and stupid, and thus should be removed.
