From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take21 2/4] kevent: poll/select() notifications.
Date: Sat, 28 Oct 2006 14:08:15 +0400
Message-ID: <20061028100815.GB15038@2ka.mipt.ru>
References: <11619654012104@2ka.mipt.ru> <45432B1A.8020503@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53166 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1752074AbWJ1KIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2006 06:08:51 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <45432B1A.8020503@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 28, 2006 at 12:04:10PM +0200, Eric Dumazet (dada1@cosmosbay=
=2Ecom) wrote:
> Evgeniy Polyakov a =C3=A9crit :
>=20
> >+	file =3D fget(k->event.id.raw[0]);
> >+	if (!file)
> >+		return -ENODEV;
>=20
> Please, do us a favor, and use EBADF instead of ENODEV.
>=20
> EBADF : /* Bad file number */
>=20
> ENODEV : /* No such device */
>=20
> You have many ENODEV uses in your patches and that really hurts.

Ok :)

> Eric

--=20
	Evgeniy Polyakov
