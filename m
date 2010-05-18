From: David Miller <davem@davemloft.net>
Subject: Re: tcp md5 fraglist...
Date: Mon, 17 May 2010 23:35:37 -0700 (PDT)
Message-ID: <20100517.233537.62328306.davem@davemloft.net>
References: <20100517.231403.148532542.davem@davemloft.net>
	<1274164224.2567.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42521
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755263Ab0ERGf2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 02:35:28 -0400
In-Reply-To: <1274164224.2567.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 May 2010 08:30:24 +0200

> Le lundi 17 mai 2010 =E0 23:14 -0700, David Miller a =E9crit :
>> Eric, would you please formally submit that tcp md5 fraglist
>> fix to net/ipv4/tcp.c with proper signoffs?
>>=20
>> Thanks!
>=20
> Sure, will do, but I doubt it is a real problem, because GRO or RSC
> should not coalesce two segments with MD5 signature (they are guarant=
eed
> to differ for each segment ?)

Right, and I just checked that GRO does in fact check if the TCP
options are different in any way.
