From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re : [RFC] old stuff - Kernel Bug Tracker Bug 7398
Date: Thu, 27 Dec 2007 01:07:22 +0000 (GMT)
Message-ID: <228293.73285.qm@web25712.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 394780@bugs.debian.org
To: Andreas Henriksson <andreas@fatal.se>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25712.mail.ukl.yahoo.com ([217.12.10.54]:41753 "HELO
	web25712.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751711AbXL0BOG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Dec 2007 20:14:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> While looking over the old remaining bugs reported against iproute in
> Debian I came across http://bugs.debian.org/394780 which has also bee=
n
> reported as http://bugzilla.kernel.org/show_bug.cgi?id=3D7398 (please
> see the old comments here).
> [...]
> The bugs last comment was from Pierre asking about a patch he
> provided:
> > I am sorry, I didn't mean to break anything... What about a sysctl
> > option, to give the user the possibility to disable the hack? See
> > attached patch. I can't really see any drawback to that. Please
> > review and consider re-opening the bug.

This patch just by-passes the hack altogether. I haven't looked into th=
e
details of what the hack does, nor do I know about vic or vat, so this
patch may not be the optimal solution. Anyway, I used it on my box, and
it did do the trick.

There must be other people who stumbled across this quirk. At the very
least, it should be clearly documented, where a sysadmin setting up
multicast streaming would find it.


--=20
Pierre Ynard
=46or hire - http://www.linkfanel.net/resume.pdf
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."



      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail http://mail.yahoo.fr
