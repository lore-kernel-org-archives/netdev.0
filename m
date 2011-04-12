From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetpeer: reduce stack usage
Date: Tue, 12 Apr 2011 13:58:48 -0700 (PDT)
Message-ID: <20110412.135848.104047454.davem@davemloft.net>
References: <1302597580.3233.14.camel@edumazet-laptop>
	<20110412235126.63841dfe.shimoda.hiroaki@gmail.com>
	<1302620123.3233.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shimoda.hiroaki@gmail.com, lkml@scotdoyle.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54273
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932155Ab1DLU7Y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 16:59:24 -0400
In-Reply-To: <1302620123.3233.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Apr 2011 16:55:23 +0200

> Le mardi 12 avril 2011 =E0 23:51 +0900, Hiroaki SHIMODA a =E9crit :
>=20
>> I couldn't understand that actually cleanup_once() was called
>> from inet_getpeer() and then the stack overflow was hit,
>> but this patch surely reduces stack usage.
>>=20
>> Reviewed-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
>>=20
>=20
> Well, I dont believe we actually hit a stack overflow in Scot Doyle
> reported crashes, but it certainly is better to use a bit less stack
> anyway ;)
>=20
> Thanks for reviewing !

Applied, thanks everyone.
