From: =?ISO-8859-2?Q?Rafa=B3_Bilski?= <rafalbilski@interia.pl>
Subject: Re: Natsemi DP83815 driver spaming
Date: Tue, 01 May 2007 21:10:30 +0200
Message-ID: <463790A6.50003@interia.pl>
References: <46365887.3010705@interia.pl> <20070430205522.abad2481.akpm@linux-foundation.org> <20070501084639.GA528@sirena.org.uk> <46371590.4090004@interia.pl> <20070501180830.GA31630@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp35.poczta.interia.pl ([80.48.65.35]:32894 "EHLO
	smtp4.poczta.interia.pl" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161792AbXEATKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 15:10:44 -0400
In-Reply-To: <20070501180830.GA31630@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> eth0: Media selection timer tick.
>> eth0: possible phy reset: re-initializing
>=20
> This is why the reset is being triggered - it's a workaround for a ha=
rdware
> bug which checks to make sure the hardware is in the state that the
> kernel thinks it is is going off.  The code has this explanatory comm=
ent:
>=20
>  * 2) check for sudden death of the NIC:
>  *    It seems that a reference set for this chip went out with incor=
rect info,
>  *    and there exist boards that aren't quite right.  An unexpected =
voltage
>  *    drop can cause the PHY to get itself in a weird state (basicall=
y reset).
>  *    NOTE: this only seems to affect revC chips.

Yes. I have revision C chip.
=20
> I'd suggest checking your power supply as a first step.

5,25V when not connected. 5,04V when connected to Wyse. I don't have ac=
cess to=20
osciloscope.
I will check if this code is nedded. If it is then I will try to get ne=
w power=20
supply.
=20
> [BTW, as Andrew said please don't drop people from the CC.]
OK. Will not happen again.

Rafa=B3



----------------------------------------------------------------------
Kasia Cichopek eksponuje biust =20
>>> http://link.interia.pl/f1a6f

