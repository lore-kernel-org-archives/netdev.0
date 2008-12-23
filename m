From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while
 a compound statement
Date: Tue, 23 Dec 2008 09:26:26 -0800
Message-ID: <1230053186.1447.9.camel@brick>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	 <20081222191507.11807.50794.stgit@vmbox.hanneseder.net>
	 <m3hc4voo2a.fsf@maximus.localdomain>
	 <a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com>
	 <m3ocz2ua3w.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?H=E5kon_L=F8vdal?= <hlovdal@gmail.com>,
	Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:47081 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbYLWR0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 12:26:31 -0500
In-Reply-To: <m3ocz2ua3w.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-23 at 17:31 +0100, Krzysztof Halasa wrote:
> "H=C3=A5kon L=C3=B8vdal" <hlovdal@gmail.com> writes:
>=20
> > For this specific issue the important aspect is to improve readabil=
ity
> > (and not just eventually satisfy some warning from a tool), which I
> > assume there is no disagrement on.
>=20
> Precisely.
>=20
> > Now what constitutes improved
> > readbility on the other hand is another issue, and I guess there ar=
e
> > next to as many oppinions as developers... :)
>=20
> Yes. Thus the brackets (or lack of them) of do-while loops should
> never be forced as a part of coding standard/tools. This is just an
> unimportant detail of personal style and trying to force it is simply
> damaging to all of us.
>=20
> > Of secondary importance is the benefit that always using brackets
> > makes them much more merge friendly.
>=20
> There are many ways to make the code more merge friendly at a cost of
> readability. Hope we don't go this way.

Linus himself added that particular warning to sparse...may want to che=
ck
with him the reason for it.

Harvey

