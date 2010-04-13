From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 23:46:19 +0200
Message-ID: <1271195179.16881.575.camel@edumazet-laptop>
References: <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>
	 <4BC47F38.5040509@gmail.com> <1271169741.16881.437.camel@edumazet-laptop>
	 <20100413.144340.138717714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: smulcahy@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, ben@decadent.org.uk, aabdulla@nvidia.com,
	572201@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:35384 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114Ab0DMVqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 17:46:25 -0400
Received: by bwz19 with SMTP id 19so19382bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 14:46:23 -0700 (PDT)
In-Reply-To: <20100413.144340.138717714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 14:43 -0700, David Miller a =C3=A9crit :
> Do you really come to the conclusion that TSO is broken with the abov=
e
> test results?
>=20
> I would conclude that there is a TX checksumming issue, since merely
> turning TSO off does not fix the problem whereas turning TX
> checksumming off does.

Indeed, we clarified the point and it is a TX checksum issue.


