From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: Aw: Re: IPv4 / IPv6 over IPv4 IPsec tunnel: setting the DF bit
Date: Thu, 30 Jan 2014 16:26:24 +0100 (CET)
Message-ID: <trinity-a9289159-8d0c-4ad1-8586-e8987e008643-1391095583899@3capp-gmx-bs16>
References: <trinity-bc5263ea-896d-4350-aa80-fd2895b54b3b-1391084710336@3capp-gmx-bs28>,
 <20140130142116.GD25336@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:49176 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbaA3P0Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 10:26:25 -0500
Received: from 3capp-gmx-bs16.server.lan ([172.19.170.68]) by
 mrigmx.server.lan (mrigmx001) with ESMTP (Nemesis) id
 0MDSWR-1W3de90IGL-00GrxK for <netdev@vger.kernel.org>; Thu, 30 Jan 2014
 16:26:24 +0100
In-Reply-To: <20140130142116.GD25336@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,
thanks once again for the quick reply.

Quickly checked the ip manpage. I'm clear about the case where pmtudisc=
 is in effect (default) - the DF bit must be TRUE in this case, for PMT=
UD to work.

Not sure what you meant by:

"but DF bit should get copied from inner packet up to tunnel header in =
every
case"

Do you mean the nopmtudisc case?

Also, IPv6 must be different then - there's no DF bit to be copied.

Could you please clarify?

best regards, Simon
=C2=A0
=C2=A0

Gesendet:=C2=A0Donnerstag, 30. Januar 2014 um 15:21 Uhr
Von:=C2=A0"Hannes Frederic Sowa" <hannes@stressinduktion.org>
An:=C2=A0"Simon Schneider" <simon-schneider@gmx.net>
Cc:=C2=A0netdev@vger.kernel.org
Betreff:=C2=A0Re: IPv4 / IPv6 over IPv4 IPsec tunnel: setting the DF bi=
t
On Thu, Jan 30, 2014 at 01:25:10PM +0100, Simon Schneider wrote:
> Hi,
> for the scenarios
> - IPv4 over IPv4 IPsec tunnel
> - IPv6 over IPv4 IPsec tunnel
>
> I wonder how the DF bit of the outer (encrypted) packet is set.
>
> There are generally three options:
> - DF bit always 0
> - DF bit always 1
> - DF bit copied from inner packet

There is a pmtudisc knob on ip tunnel ... to force DF bit on outgoing p=
ackets,
but DF bit should get copied from inner packet up to tunnel header in e=
very
case.

Greetings,

Hannes
=C2=A0
