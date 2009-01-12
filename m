From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 22:50:01 +0100
Message-ID: <20090112215001.GG23848@one.firstfloor.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901122230.25976.rdenis@simphalempin.com> <20090112205547.GE23848@one.firstfloor.org> <200901122247.22059.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, Valdis.Kletnieks@vt.edu,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56362 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbZALVfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 16:35:34 -0500
Content-Disposition: inline
In-Reply-To: <200901122247.22059.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 10:47:21PM +0200, R=E9mi Denis-Courmont wrote:
> Le lundi 12 janvier 2009 22:55:47 Andi Kleen, vous avez =E9crit=A0:
> > Fair point, although I'm afraid you didn't do a very good
> > job explaining your reasons, so it sounds like a
> > quite arbitary decision.
>=20
> Fair enough. It's just way too much interface/adaptation work compare=
d to the=20
> benefit. Especially considering that it would be much easier, and alm=
ost as=20
> secure, with a "relaxed" SECCOMP.=20

What system calls would you want in a relaxed SECCOMP?

> And on top of that, it's causing=20
> unnecessary overhead (we're also interested in those small Linux-base=
d=20

Would be interesting to try that out -- just adding two memcpyies to=20
the existing code and see how much slower it gets. My guess
would be not very, even e.g. on a Atom system (which are really
not all that slow).

Presumably you could always #ifdef it if it's really a problem
on some specific system. That would be needed anyways for=20
non linux systems.

-And

--=20
ak@linux.intel.com -- Speaking for myself only.
