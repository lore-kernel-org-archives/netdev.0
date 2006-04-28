From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 3/32] rt2x00: use pci_*_consistent for DMA mapping
Date: Fri, 28 Apr 2006 15:39:38 +0200
Message-ID: <200604281539.39166.IvDoorn@gmail.com>
References: <200604280002.52839.IvDoorn@gmail.com> <200604281524.11670.IvDoorn@gmail.com> <200604281533.57372.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4027733.8sgTidNExP";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.185]:50462 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030398AbWD1Nia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 09:38:30 -0400
Received: by nproxy.gmail.com with SMTP id n29so1580751nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 06:38:29 -0700 (PDT)
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200604281533.57372.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4027733.8sgTidNExP
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 15:33, Michael Buesch wrote:
> On Friday 28 April 2006 15:24, you wrote:
> > struct data_ring{
> > 	/*
> > 	 * net_device where this ring belongs to.
> > 	 */
> > 	struct net_device			*net_dev;
> >=20
> > 	/*
> > 	 * Work structure for bottom half interrupt handling.
> > 	 */
> > 	struct work_struct			irq_work;
> >=20
> > 	/*
> > 	 * Base address for the device specific data entries.
> > 	 */
> > 	void					*entry;
> >=20
> > 	/*
> > 	 * TX queue statistic info.
> > 	 */
> > 	struct ieee80211_tx_queue_stats_data	stats;
> >=20
> > 	/*
> > 	 * TX Queue parameters.
> > 	 */
> > 	struct ieee80211_tx_queue_params	tx_params;
> >=20
> > 	/*
> > 	 * Base address for data ring.
> > 	 */
> > 	dma_addr_t				data_dma;
> > 	void					*data_addr;
> >=20
> > 	/*
> > 	 * Index variables.
> > 	 */
> > 	u8					index;
> > 	u8					index_done;
> >=20
> > 	/*
> > 	 * Size of device specific data entry structure.
> > 	 */
> > 	u16					entry_size;
> >=20
> > 	/*
> > 	 * Size of packet and descriptor in bytes.
> > 	 */
> > 	u16					data_size;
> > 	u16					desc_size;
> > } __attribute__ ((packed));
>=20
> Why is this packed? I don't believe you write such a data
> structure (which contains dscape specific structs) to some
> device registers.

I can't remember actually, I believe this came from a patch we had received
last year with the legacy drivers from a user.=20
Since then most structures have received the __attribute__ ((packed)) tag.
I'll create a patch to remove the tags where they are not needed.

--nextPart4027733.8sgTidNExP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUhsbaqndE37Em0gRAsqdAKDdrc1jRsT6lTczw1HSoo5H7ehoCgCcC/7J
K68S7PG2NuhUfukUuyIvUvI=
=3G1m
-----END PGP SIGNATURE-----

--nextPart4027733.8sgTidNExP--
