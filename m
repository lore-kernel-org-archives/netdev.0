From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] bonding: send ARP requests on interfaces other than
 the primary for tlb/alb
Date: Wed, 30 Sep 2009 07:49:04 +0200
Message-ID: <4AC2F150.4060509@gmail.com>
References: <20090930054015.GA5231@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43983 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbZI3FtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 01:49:18 -0400
In-Reply-To: <20090930054015.GA5231@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On 30-09-2009 07:20, Eric Dumazet wrote:
> ...
>>> +	/* Choose an output channel for the ARP frame */
>>> +	tx_slave =3D rlb_choose_channel(skb, bond);
>>> =20
>>> -		/* The ARP relpy packets must be delayed so that
>>> -		 * they can cancel out the influence of the ARP request.
>>> -		 */
>> COmments should have the following form :
>> /*
>>  * This is a fine comment
>>  */
>=20
> It's "The preferred style for long (multi-line) comments [...]".

Yes I agree.

We keep old comments as they are, but for new code submission, we
try to follow common practices.
I know it seems odd, but in the end it helps code readability.

Of course, I would have not point this without another more interesting=
=20
stuff in the review process :)


