From: David Miller <davem@davemloft.net>
Subject: Re: inetpeer with create==0
Date: Thu, 03 Mar 2011 00:32:29 -0800 (PST)
Message-ID: <20110303.003229.229764095.davem@davemloft.net>
References: <AANLkTi=Ty+C3b9U+151dUMpgGiwG3AE4dMmc3djWmp6v@mail.gmail.com>
	<20110302.224220.179921025.davem@davemloft.net>
	<1299137977.2456.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751325Ab1CCIbw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 03:31:52 -0500
In-Reply-To: <1299137977.2456.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Mar 2011 08:39:37 +0100

> Le mercredi 02 mars 2011 =E0 22:42 -0800, David Miller a =E9crit :
>> Actually, back to the original topic, I wonder how bad it is to simp=
ly
>> elide the recheck in the create=3D=3D0 case anyways.  Except for the=
 ipv4
>> fragmentation wraparound protection values, perfect inetpeer finding
>> is not necessary for correctness.  And IPv4 fragmentation always cal=
ls
>> inetpeer with create!=3D0.
>=20
> We could use a seqlock, to detect that a writer might have changed
> things while we did our RCU lookup ?

That would certainly work.
