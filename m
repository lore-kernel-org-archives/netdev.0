From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while a compound statement
Date: Tue, 23 Dec 2008 17:31:15 +0100
Message-ID: <m3ocz2ua3w.fsf@maximus.localdomain>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191507.11807.50794.stgit@vmbox.hanneseder.net>
	<m3hc4voo2a.fsf@maximus.localdomain>
	<a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Hannes Eder" <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?utf-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:56375 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbYLWQbS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 11:31:18 -0500
In-Reply-To: <a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com>
 (=?utf-8?Q?=22H=C3=A5kon_L=C3=B8vdal=22's?= message of "Tue\, 23 Dec 2008
 00\:44\:25 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"H=C3=A5kon L=C3=B8vdal" <hlovdal@gmail.com> writes:

> For this specific issue the important aspect is to improve readabilit=
y
> (and not just eventually satisfy some warning from a tool), which I
> assume there is no disagrement on.

Precisely.

> Now what constitutes improved
> readbility on the other hand is another issue, and I guess there are
> next to as many oppinions as developers... :)

Yes. Thus the brackets (or lack of them) of do-while loops should
never be forced as a part of coding standard/tools. This is just an
unimportant detail of personal style and trying to force it is simply
damaging to all of us.

> Of secondary importance is the benefit that always using brackets
> makes them much more merge friendly.

There are many ways to make the code more merge friendly at a cost of
readability. Hope we don't go this way.
--=20
Krzysztof Halasa
