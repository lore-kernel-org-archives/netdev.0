From: Pascal GREGIS <pgs@synerway.com>
Subject: Re: need some help on a backport of r8169
Date: Tue, 27 Feb 2007 12:02:43 +0100
Message-ID: <20070227110243.GA15657@venus.synerway.com>
References: <20070226170941.GA17587@venus.synerway.com> <20070226234831.GA12830@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.synerway.com ([84.14.10.249]:34000 "EHLO
	stargate.synerway.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbXB0LCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 06:02:47 -0500
Received: from kamino.synerway.com (kamino [172.16.1.21])
	by stargate.synerway.com (Postfix) with ESMTP id EE5FD75C16F
	for <netdev@vger.kernel.org>; Tue, 27 Feb 2007 12:37:56 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20070226234831.GA12830@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancois Romieu a =E9crit, le Tue 27 Feb 2007 =E0 12:48:31AM :
> Pascal GREGIS <pgs@synerway.com> :
> [...]
> > Could anyone take a look at my patch and tell me what is missing,
>=20
> - It lacks the adequate registers init sequence for a 8168 for instan=
ce.
> - Fix went in between 2.6.11 and 2.6.12.
Where is this init sequence in the driver? I searched in the code and d=
idn't find something that could satisfy, then I took the 2.6.12.3 r8169=
=2Ec, put it in the 2.6.11.11 source tree, applied my patch, changed sy=
nchronize_sched(); to synchronize_kernel(); because the symbol was unkn=
own and then I could turn eth1 on and assign it an ip address but the r=
x and tx count never grew and when I turned eth0 down (a 8139 card) eth=
1 didn't reply to ping anymore.
=20
>=20
> There are 59 r8169 related patches between 2.6.12 and current. Only a=
 few
> of those break the API. I'll give it a try tomorrow evening.
Hmm... you wrote this mail at 00 h 48 this morning, what did you mean b=
y tomorrow evening?


Merci

Pascal
