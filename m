From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [patch 2.6.13 0/5] normalize calculations of rx_dropped
Date: Tue, 25 Oct 2005 21:50:01 +0200
Message-ID: <200510252150.07933.ioe-lkml@rameria.de>
References: <09122005104858.332@bilbo.tuxdriver.com> <20051024215751.GH28212@tuxdriver.com> <435D8717.9000107@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1183262.5eQGP4NlsH";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932332AbVJYTuQ@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <435D8717.9000107@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1183262.5eQGP4NlsH
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 25 October 2005 03:15, Ben Greear wrote:
> rx_errors:  Total of all rx errors

If it is a total, then we don't need to store it, since we can calculate
that explicity on request, no?

> rx_dropped:  Dropped on receive, usually due to kernel being over-worked.
> rx_length:  Dropped because pkt-length was invalid.
> rx_over:  Dropped because we over-ran the NIC's rx buffers.
> rx_crc:  Packets received with bad CRC errors.
> rx_frame:  Framing errors (errors at the physical layer), usually cable or hardware error.
> rx_fifo:  Dropped due to Kernel buffers being full (I guess rx-over could be NIC only, rx-fifo be kernel/driver only.)
> rx_missed:  Dropped due to not handling IRQ in time.

Regards

Ingo Oeser


--nextPart1183262.5eQGP4NlsH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBDXoxvU56oYWuOrkARAtBPAJ9uElUDEMgCPBFkMM25jCeKEMHMCwCg32Id
we2zXE8r3WK3GHYJCVrw6cc=
=Mqay
-----END PGP SIGNATURE-----

--nextPart1183262.5eQGP4NlsH--
