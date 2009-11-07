From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 02/02: xt_connlimit: fix regression caused by zero
 family value
Date: Fri, 06 Nov 2009 18:08:27 -0800 (PST)
Message-ID: <20091106.180827.04637637.davem@davemloft.net>
References: <4AF31818.3030103@trash.net>
	<alpine.LSU.2.00.0911051943130.25147@obet.zrqbmnf.qr>
	<4AF43782.50604@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59329
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754280AbZKGCIC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 21:08:02 -0500
In-Reply-To: <4AF43782.50604@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Patrick McHardy <kaber@trash.net>
Date: Fri, 06 Nov 2009 15:49:38 +0100

> Jan Engelhardt wrote:
>> On Thursday 2009-11-05 19:23, Patrick McHardy wrote:
>>>    netfilter: xt_connlimit: fix regression caused by zero family va=
lue
>>>   =20
>>>    Commit v2.6.28-rc1~7172~1092~2 was slightly incomplete; not all
>>>    instances of par->match->family were changed to par->family.
>>>   =20
>>>    Netfilter bugzilla #610.
>>=20
>> Hold it.
>> git would never output ~7172~1092~2 because ~8266 would be much simp=
ler.
>>=20
>> I originally wrote "Commit v2.6.28-rc1~717^2~109^2~2", but one of yo=
ur=20
>> programs seems to eat commit messages or more.
>=20
> Indeed, my email client displays ^2 as =B2, which cut and paste trans=
forms
> to 2 :)

Ok, so I'll apply Jan's fixed up version, thanks!
