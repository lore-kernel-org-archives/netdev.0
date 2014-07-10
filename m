From: 'Ezequiel Garcia' <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v3 1/4] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Thu, 10 Jul 2014 14:07:16 -0300
Message-ID: <20140710170716.GA17727@arch.cereza>
References: <1404758751-2346-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1404758751-2346-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140707221823.GC16677@electric-eye.fr.zoreil.com>
 <20140710151904.GA5283@arch.cereza>
 <063D6719AE5E284EB5DD2968C1650D6D172700F9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:57503 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751701AbaGJRIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 13:08:09 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D172700F9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 Jul 03:26 PM, David Laight wrote:
> From: Ezequiel Garcia
> ...
> > > > +/* Compare tcam data bytes with a pattern */
> > > > +static bool mvpp2_prs_tcam_data_cmp(struct mvpp2_prs_entry *pe=
,
> > > > +				    unsigned int offs, unsigned int size,
> > > > +					   unsigned char *bytes)
> > > > +{
> > > > +	unsigned char byte, mask;
> > > > +	int i;
>=20
> Hmm. should be 'unsigned int' for the comparison against 'size'.
>=20

Right. I've reworked this entirely, because it was barely readable,
and now the size parameter is gone.

> > > > +
> > > > +	for (i =3D 0; i < size; i++) {
> > > > +		mvpp2_prs_tcam_data_byte_get(pe, offs + i, &byte, &mask);
> > > > +
> > > > +		if (byte !=3D bytes[i])
> > > > +			return false;
> > >
> > > Please reduce the scope of "byte" and "mask".
> > >
> >=20
> > Agreed. This applies on several other places, I'll fix them all.
> >=20
> > > > +	}
> > > > +	return true;
>=20
> Not sure about other people, but I prefer variables to be defined
> at the top of a function so that I can find them.
> Minimising the scope tends to make code harder to read.
>=20
> If this was a big function, then reducing the scope of 'temporary'
> variables need for a few lines (like the above loop) can make sense
> because it reduces the clutter at the top of the function.
>=20

Yeah, that makes sense. I'm fine either way; I'll be submitting v4 now
addressing most of Francois' feedback. Feel free to complain if you thi=
nk
some function is not readable enough and can be improved.

Thanks for taking a look,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
