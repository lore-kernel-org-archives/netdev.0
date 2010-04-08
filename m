From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: fix for unicast RX path optimization
Date: Thu, 08 Apr 2010 11:30:02 -0700 (PDT)
Message-ID: <20100408.113002.03363708.davem@davemloft.net>
References: <4BBDEEB0.7060003@dti2.net>
	<1270739547.2215.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jorge@dti2.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35873
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758895Ab0DHS37 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 14:29:59 -0400
In-Reply-To: <1270739547.2215.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Apr 2010 17:12:27 +0200

> Le jeudi 08 avril 2010 =E0 16:56 +0200, Jorge Boncompte [DTI2] a =E9c=
rit :
>> 	Commits 5051ebd275de672b807c28d93002c2fb0514a3c9 and
>> 5051ebd275de672b807c28d93002c2fb0514a3c9 ("ipv[46]: udp: optimize un=
icast RX
>> path") broke some programs.
>>=20
>> 	After upgrading a L2TP server to 2.6.33 it started to fail, tunnels=
 going up an
>> down, after the 10th tunnel came up. My modified rp-l2tp uses a glob=
al
>> unconnected socket bound to (INADDR_ANY, 1701) and one connected soc=
ket per
>> tunnel after parameter negotiation.
>>=20
>> 	After ten sockets were open and due to mixed parameters to
>> udp[46]_lib_lookup2() kernel started to drop packets.
>>=20
>> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable.
