From: David Miller <davem@davemloft.net>
Subject: Re: Badness at net/ipv4/inet_connection_sock.c:293
Date: Mon, 14 Dec 2009 11:24:06 -0800 (PST)
Message-ID: <20091214.112406.149143587.davem@davemloft.net>
References: <1260817033.9141.8.camel@merlyn>
	<20091214.111105.224947761.davem@davemloft.net>
	<4B269065.5000601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: john.dykstra1@gmail.com, lists@nerdbynature.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932504AbZLNTYE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2009 14:24:04 -0500
In-Reply-To: <4B269065.5000601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Dec 2009 20:22:13 +0100

> Le 14/12/2009 20:11, David Miller a =E9crit :
>> From: John Dykstra <john.dykstra1@gmail.com>
>> Date: Mon, 14 Dec 2009 18:57:13 +0000
>>=20
>>> That test was changed to match a change in the return values of
>>> tcp_ack().  No logic change was intended.
>>=20
>> As Eric pointed out, changing tcp_ack()'s behavior effects state
>> transitions out of SYN_ACK, so this commit is very likely the culpri=
t.
>>=20
>> I usually see 2 or 3 three of these bug triggers in the first ten
>> minutes after bootup and I haven't seen one yet in 20 minutes
>> with the commit reverted.
>>=20
>> This change is definitely wrong.
>=20
> Hmm, I didnt yet spotted the problem, just gave some hints ...

You did point out that tcp_ack's behavior could influence
TCP_SYN_* state behavior, and that's all I claimed.

My "definitely wrong" conclusion was based upon not triggering
the warning for several minutes (which turned out to be a fluke),
not your analysis.
