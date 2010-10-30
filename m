From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: fix fallback tunnel setup
Date: Sat, 30 Oct 2010 16:21:38 -0700 (PDT)
Message-ID: <20101030.162138.59683924.davem@davemloft.net>
References: <1288291679.2711.1.camel@edumazet-laptop>
	<1288293079.2711.19.camel@edumazet-laptop>
	<4CC9CF06.1090806@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39118
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753921Ab0J3XVO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Oct 2010 19:21:14 -0400
In-Reply-To: <4CC9CF06.1090806@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 28 Oct 2010 23:29:10 +0400

> On 10/28/2010 11:11 PM, Eric Dumazet wrote:
>> Le jeudi 28 octobre 2010 =E0 20:47 +0200, Eric Dumazet a =E9crit :
>>> Le jeudi 28 octobre 2010 =E0 11:41 -0700, David Miller a =E9crit :
>>>> I am still able to revert this I think without screwing up
>>>> publicly visible history, so I will double check and do the
>>>> revert if I can.
>>>
>>> Cool, I'll provide a patch in a couple of minutes, when tested.
>>>
>>=20
>> I believe the right fix is this one, Pavel what do you think ?
>=20
> Indeed. I missed the fact, that the gre driver uses ndo_init for
> all devices including the fb one :(
>=20
> Acked-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
