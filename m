From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 23:27:26 +0300
Message-ID: <20090112202726.GA2169@ioremap.net>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901122147.57731.rdenis@simphalempin.com> <20090112201435.GC23848@one.firstfloor.org> <200901122215.27842.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, Valdis.Kletnieks@vt.edu,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?B?UsOpbWk=?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:60693 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753279AbZALU11 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 15:27:27 -0500
Content-Disposition: inline
In-Reply-To: <200901122215.27842.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 10:15:27PM +0200, R=C3=A9mi Denis-Courmont (rde=
nis@simphalempin.com) wrote:
> > I don't think that's given. It would need some restructuring,
> > but I think the end result would be likely worth it.
>=20
> A normal DVD would be over 30 megabytes per seconds once decoded, jus=
t for the=20
> video. And remember vmsplice() is not allowed by SECCOMP. Media playe=
rs have=20
> assembly-coded memory copy optimizations (like the kernel) for some r=
eason.

Just a note: memory copy is way too faster than 30 mb/s, and very likel=
y
it is not the memory copy, but (de)compression, since likely all modern
codecs are limited by the CPU and not the memory bandwidth.

--=20
	Evgeniy Polyakov
