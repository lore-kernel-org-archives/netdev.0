From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 22:47:21 +0200
Message-ID: <200901122247.22059.rdenis@simphalempin.com>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <200901122230.25976.rdenis@simphalempin.com> <20090112205547.GE23848@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:51812 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbZALUr0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 15:47:26 -0500
In-Reply-To: <20090112205547.GE23848@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 janvier 2009 22:55:47 Andi Kleen, vous avez =E9crit=A0:
> Fair point, although I'm afraid you didn't do a very good
> job explaining your reasons, so it sounds like a
> quite arbitary decision.

=46air enough. It's just way too much interface/adaptation work compare=
d to the=20
benefit. Especially considering that it would be much easier, and almos=
t as=20
secure, with a "relaxed" SECCOMP. And on top of that, it's causing=20
unnecessary overhead (we're also interested in those small Linux-based=20
handsets that aren't as fast and power-hungry as desktop PCs).

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
