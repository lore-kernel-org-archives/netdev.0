From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 02/02: xt_connlimit: fix regression caused by zero
 family value
Date: Fri, 06 Nov 2009 15:49:38 +0100
Message-ID: <4AF43782.50604@trash.net>
References: <4AF31818.3030103@trash.net> <alpine.LSU.2.00.0911051943130.25147@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0911051943130.25147@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2009-11-05 19:23, Patrick McHardy wrote:
>>    netfilter: xt_connlimit: fix regression caused by zero family val=
ue
>>   =20
>>    Commit v2.6.28-rc1~7172~1092~2 was slightly incomplete; not all
>>    instances of par->match->family were changed to par->family.
>>   =20
>>    Netfilter bugzilla #610.
>=20
> Hold it.
> git would never output ~7172~1092~2 because ~8266 would be much simpl=
er.
>=20
> I originally wrote "Commit v2.6.28-rc1~717^2~109^2~2", but one of you=
r=20
> programs seems to eat commit messages or more.

Indeed, my email client displays ^2 as =B2, which cut and paste transfo=
rms
to 2 :)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
