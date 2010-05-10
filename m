From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Pull request: bluetooth-next-2.6 2010-05-10
Date: Mon, 10 May 2010 12:41:09 +0200
Message-ID: <1273488069.375.30.camel@localhost.localdomain>
References: <cover.1273484094.git.marcel@holtmann.org>
	 <20100510.024750.45124664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:32913 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580Ab0EJKlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 06:41:47 -0400
In-Reply-To: <20100510.024750.45124664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > this is the big merge for the L2CAP Enhanced Retransmission support=
 work
> > done by Gustavo F. Padovan. All other changes are small cleanups.
>=20
> Yeah, "big", as in "too big".
>=20
> Please sync with me more often so you don't have to obliterate the
> list with unacceptable 64 posting patch bombs.  Nobody is going to
> really review such a huge patch set in any serious manner, which
> makes posting those patches almost worthless.
>=20
> Anything more than about 10 or 20 at a time is way too much.

normally we don't have any big changes in the Bluetooth kernel side.
This is the first one that adds a big set of features. And it is limite=
d
to the L2CAP layer. I took it out of last kernel release since it was
incomplete and would not have been useful. Right now it is in a stage
where it becomes usable. Only new profiles like the Health Medical stuf=
f
is making use of these features for now. However in the future more and
more profile will requires support for it.

The number of patches are not getting smaller. Except I arbitrarily
merge them together. I am not planning to do that since I think it is
not a good idea at all. And the patches have been reviewed by Jo=C3=A3o=
 Paulo
Rechi Vita who worked with Gustavo on these changes.

So do you want to postpone this for 2.6.35 merge window?

Regards

Marcel


