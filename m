From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: Cleanup redundant tests on unsigned
Date: Sat, 24 Oct 2009 06:19:39 -0700 (PDT)
Message-ID: <20091024.061939.101469808.davem@davemloft.net>
References: <4AE1D553.8010406@gmail.com>
	<4AE1D4FE.5090902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roel.kluin@gmail.com, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753325AbZJXNTP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2009 09:19:15 -0400
In-Reply-To: <4AE1D4FE.5090902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Oct 2009 18:08:30 +0200

> Roel Kluin a =E9crit :
>> The variables are unsigned so the `< 0' test always fails, the
>> other part of the test catches wrapped values.
>>=20
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---
>=20
> I believe such patches were posted in the past.
>=20
> General consensus is that compiler is able to do this optimization fo=
r us,
> and reader doesnt have to ask to himself : "Is the test safe enough ?=
"

Conversely, the reader can say "Wow this can be negative?  There's
tests missing elsewhere! ... oh, nevermind it's unsigned"

That really wastes people's time too.

I suspect I'll apply these patches. :-)

