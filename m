From: David Miller <davem@davemloft.net>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Sun, 09 Jan 2011 23:19:03 -0800 (PST)
Message-ID: <20110109.231903.42797119.davem@davemloft.net>
References: <373539.88491.qm@web37603.mail.mud.yahoo.com>
	<1294643276.2709.877.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oakad@yahoo.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751292Ab1AJHSb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 02:18:31 -0500
In-Reply-To: <1294643276.2709.877.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Jan 2011 08:07:56 +0100

> Le dimanche 09 janvier 2011 =E0 22:33 -0800, Alex Dubov a =E9crit :
>> I managed to work around the issue by clearing the NETIF_F_IP_CSUM
>> feature flag of the gianfar network driver, so it appears the bug is
>> indeed somewhere there.
>>=20
>=20
> Its incredible how TCP timestamps can be "usual suspects" ;)

Or RTC chips! :-)
