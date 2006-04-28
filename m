From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 20/32] rt2x00: byte ordering correctness
Date: Fri, 28 Apr 2006 15:42:29 +0200
Message-ID: <200604281542.29534.mb@bu3sch.de>
References: <200604280003.12743.IvDoorn@gmail.com> <20060428131430.GA3288@infradead.org> <200604281531.06896.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4265501.Ls4M1kRU4r";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:23704
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030395AbWD1Ngz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 09:36:55 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200604281531.06896.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4265501.Ls4M1kRU4r
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 15:31, you wrote:
> On Friday 28 April 2006 15:14, Christoph Hellwig wrote:
> > On Fri, Apr 28, 2006 at 02:59:23PM +0200, Ivo van Doorn wrote:
> > > I am not sure if that would be a wise idea,
> > > there is no byte ordering done in rt2500usb except for the EEPROM
> > > contents which is little endian.
> > > So when the module is used on a normal x86 platform, there won't be
> > > any big endian structures or fields.
> >=20
> > Well, then you'll need __le* annotation and the le*_to_cpu/cpu_to_le*
> > instead.  Any new driver should be endian clean.
>=20
> Not exactly true for rt2570, to correctly operate with the device, no
> endian conversions should be made at all. Not to big endian and not
> to little endian. The register should be send as a regular value with the
> byteordering equal to the byteordering of the currently used CPU.
> It has been tested to send only little endian or big endian values to
> the device on all CPU's, and in all cases it meant that the device would =
not function on
> CPU's with the other byte ordering.

I guess you are confusing something here:
MMIO access versus values in structs (for example) that=20
are accessed through DMA (for example).

=2D-=20
Greetings Michael.

--nextPart4265501.Ls4M1kRU4r
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEUhvFlb09HEdWDKgRAtJtAKCvq6oWc50FrFjEeVD5ihv3IO8fZwCfadJe
RnXYHi8CJAuO0R9JttGeRkw=
=61Hn
-----END PGP SIGNATURE-----

--nextPart4265501.Ls4M1kRU4r--
