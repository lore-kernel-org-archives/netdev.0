From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 12:06:56 -0800 (PST)
Message-ID: <20110218.120656.104048936.davem@davemloft.net>
References: <1298039252.6201.66.camel@edumazet-laptop>
	<4D5E8655.5070304@trash.net>
	<20110218145850.GF2939@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751732Ab1BRUGU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 15:06:20 -0500
In-Reply-To: <20110218145850.GF2939@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 18 Feb 2011 15:58:51 +0100

> Fri, Feb 18, 2011 at 03:46:45PM CET, kaber@trash.net wrote:
>>Am 18.02.2011 15:27, schrieb Eric Dumazet:
>>> Le vendredi 18 f=E9vrier 2011 =E0 15:14 +0100, Jiri Pirko a =E9crit=
 :
>>>=20
>>>> Do not know how to do it better. As for percpu variable, not only
>>>> origdev would have to be remembered but also probably skb pointer =
to
>>>> know if it's the first run on the skb or not. Can't really figure =
out a
>>>> better solution. Can you?
>>>=20
>>> I'll try and let you know.
>>
>>Why not simply do a lookup on skb->iif?
>=20
> Well I was trying to avoid iterating over list of devices for each
> incoming frame.

It is not list, it is hash :-)
