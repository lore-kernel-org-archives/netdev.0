From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: do not allow watchdog to reenable transmits on
 shutdown
Date: Fri, 07 Mar 2014 13:32:46 -0800
Message-ID: <1394227966.2101.4.camel@jtkirshe-mobl.jf.intel.com>
References: <20140307020420.GA10797@amt.cnet>
	 <1394162671.2214.36.camel@jtkirshe-mobl> <20140307210009.GB5041@amt.cnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ldmtzelr4f6jLpQa6NAH"
Cc: Vladimir Davydov <VDavydov@parallels.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3123 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299AbaCGVcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2014 16:32:48 -0500
In-Reply-To: <20140307210009.GB5041@amt.cnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ldmtzelr4f6jLpQa6NAH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-07 at 18:00 -0300, Marcelo Tosatti wrote:
> On Thu, Mar 06, 2014 at 07:24:31PM -0800, Jeff Kirsher wrote:
> > On Thu, 2014-03-06 at 23:04 -0300, Marcelo Tosatti wrote:
> > >=20
> > > There is a race on the shutdown path of the e1000 driver
> > > that allows the card to DMA into free'd memory.
> > >=20
> > > The symptoms are similar to those described at=20
> > > commit d5bc77a223b0e9b9dfb002048d2b34a79e7d0b48,
> > > "e1000: don't enable dma receives until after dma address has been
> > > setup", where memory corruption is visible due to E1000_RXD_STAT_DD
> > > being written to the DMA transfer descriptor.
> > >=20
> > > Fix by not allowing the watchdog and tx fifo stall detector
> > > to re-enable E1000_TCTL_EN.
> > >=20
> > > Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
> >=20
> > Thanks I will add this to the queue.
> >=20
> > Note- there are trailing whitespace issues and 2 comments are not
> > formatted correctly.  I can fix these up if there are no other issues
> > with the patch, if you want.
>=20
> Ok, resent v2 with those fixed, must have inlined an older patch
> in the message, sorry.
>=20

Thanks Marcelo, I will update the patch in my queue when I receive it.

--=-Ldmtzelr4f6jLpQa6NAH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTGjr+AAoJEOVv75VaS+3O+wwP/As16WNCY99JZjJ5iZE6XGN4
EgP8KfbkffcvoIMFNvqTss8Je6LIXTAn1Kf3sTyEf1vra7dcVTJZwpx8b3K0s5+l
x8rEMjvoWeaGPsbsY9TH4/zr14lzURu94ucXcQ02eI3alaEaRr5kVdvvEI2M+uER
aJ+8v8coTEAtPrzKVNXA5s0AqoD0Mz4xt9BbWs72NYDTDRbFFkpKcnzUbeMdV04b
L/Zk36d89uPrJ2bYxbMpYgP0wYluiJ0aLAmc4385p7LsAZpvfNCgHiYM3UJUOYjj
iWaLKoCJ7JThKw2IhL6GRGzgkeuJySvxzNenktGjcknu4XOp7LKTb5UwpBG04MyM
nyLEK5IgwGVUWbD1t7C+HTlIkPBhWsAkUbkRbrRDMWzRyGp9uHLezKUP9BybB2s6
tdNZoCOo1gx9LwMymlfVE3rrjWU7BkaADXrjLEO6O4pM/zmEndfvkr8suMVRXlDb
biQ4XWBQvz7iiE+SdVRtCMpuyjgVC2858fPxDBt+3UMkUZisLClWdnYyTkl4wRUB
WiJFujkrbPcn+UtkQtB4I2eDsiVXvYwYV5B7ZiiiVk+XxgTG66NxbDBS7h3T+iHU
Kj5dWo7/82a55bY53+T3NPj2PaZDRSQJvh1DXTpDp30PXDjdhP7wQ/HgApsMURdW
o/COu5yLHk+lTFHPCtXL
=auGa
-----END PGP SIGNATURE-----

--=-Ldmtzelr4f6jLpQa6NAH--
