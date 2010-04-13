From: David Miller <davem@davemloft.net>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 14:43:40 -0700 (PDT)
Message-ID: <20100413.144340.138717714.davem@davemloft.net>
References: <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>
	<4BC47F38.5040509@gmail.com>
	<1271169741.16881.437.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: smulcahy@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, ben@decadent.org.uk, aabdulla@nvidia.com,
	572201@bugs.debian.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752353Ab0DMVni convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 17:43:38 -0400
In-Reply-To: <1271169741.16881.437.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Apr 2010 16:42:21 +0200

> Le mardi 13 avril 2010 =E0 15:27 +0100, stephen mulcahy a =E9crit :
>> Ok, I've tried both of the following with my reproducer
>>=20
>> 1. ethtool -K eth0 tso off
>>=20
>> RESULT: reproducer causes multiple hosts to be come unresponsive on=20
>> first run.
>>=20
>> 2. ethtool -K eth0 tx off
>>=20
>> RESULT: reproducer runs three times without any hosts becoming unres=
ponsive.
>>=20
>> -stephen
>=20
> Thanks Stephen !
>=20
> Now some brave fouls to check the 6410 lines of this driver ? ;)
>=20
> Question of the day : Why TSO is broken in forcedeth ?
> Is it generically broken or is it broken for specific NICS ?

Do you really come to the conclusion that TSO is broken with the above
test results?

I would conclude that there is a TX checksumming issue, since merely
turning TSO off does not fix the problem whereas turning TX
checksumming off does.
