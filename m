From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [BUG] igb : rtnl assert on resume
Date: Sat, 08 Oct 2011 11:26:35 -0700
Message-ID: <1318098396.23688.169.camel@jtkirshe-mobl>
References: <1318096284.5276.25.camel@edumazet-laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-i0nm3FHJuOkZWUmzCwo1"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33420 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753443Ab1JHS0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 14:26:36 -0400
In-Reply-To: <1318096284.5276.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i0nm3FHJuOkZWUmzCwo1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-10-08 at 10:51 -0700, Eric Dumazet wrote:
> Hi guys
>=20
> Not sure if its a regression (it seems linux-3.0 probably should trigger
> same trace) but I caught this on latest net-next when suspend/resume
> cycle was done :
>=20
> [ 5279.891512] RTNL: assertion failed at net/core/dev.c (1665)
> [ 5279.891515] Pid: 2785, comm: kworker/u:9 Not tainted 3.1.0-rc9+ #81
> [ 5279.891517] Call Trace:
> [ 5279.891523]  [<ffffffff814802ec>] netif_set_real_num_tx_queues+0x1ac/0=
x1c0
> [ 5279.891540]  [<ffffffffa00244d1>] igb_init_interrupt_scheme+0x151/0x4b=
0 [igb]
> [ 5279.891546]  [<ffffffffa002984d>] igb_resume+0x9d/0x160 [igb]
> [ 5279.891550]  [<ffffffff812e0b91>] pci_legacy_resume+0x41/0x60
> [ 5279.891552]  [<ffffffff812e17c0>] pci_pm_resume+0x90/0xd0
> [ 5279.891555]  [<ffffffff813896b7>] pm_op+0xe7/0x1c0
> [ 5279.891558]  [<ffffffff81389ba7>] device_resume+0xf7/0x1b0
> [ 5279.891561]  [<ffffffff8108a520>] ? async_schedule+0x20/0x20
> [ 5279.891564]  [<ffffffff81389c81>] async_resume+0x21/0x50
> [ 5279.891566]  [<ffffffff8108a59f>] async_run_entry_fn+0x7f/0x180
> [ 5279.891569]  [<ffffffff8107ca73>] process_one_work+0x123/0x480
> [ 5279.891572]  [<ffffffff8107d638>] ? manage_workers.isra.30+0x1e8/0x230
> [ 5279.891574]  [<ffffffff8107d7de>] worker_thread+0x15e/0x360
> [ 5279.891576]  [<ffffffff8107d680>] ? manage_workers.isra.30+0x230/0x230
> [ 5279.891579]  [<ffffffff8108225c>] kthread+0x8c/0xa0
> [ 5279.891583]  [<ffffffff8157fc74>] kernel_thread_helper+0x4/0x10
> [ 5279.891586]  [<ffffffff810821d0>] ? flush_kthread_worker+0xa0/0xa0
> [ 5279.891588]  [<ffffffff8157fc70>] ? gs_change+0x13/0x13
>=20
> Thanks

Any chance you can pull my net-next tree Eric to verify if the issue
still exists?

git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

I currently have 11 igb patches on that tree (which I recently
submitted) that are not in Dave's tree yet.

There have been a number of cleanup's recently, so while this is not
expected, I am not surprised at the same time since I am in the middle
of the update to igb.

We have not seen this on my local tree (which has the 11 patches plus
4-5 more patches for igb).  Almost all of them are
cleanup's/re-organizing of igb, so nothing specific to the issue you
have seen.

--=-i0nm3FHJuOkZWUmzCwo1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOkJXbAAoJEOVv75VaS+3ODkIP/RurIjGD8KrCc+uidbuKW3wE
fVsKjLG1OTzfx7DgVCIpemZEdhnQ7Do34+1L54dTXJJBvdUiGvCPyoV2MiBV1xOm
Ztk0eqaX3MeblN9JPst5xAKSzC+SrHy4fj/EmTiSOZUxmkQp5Hj0tl3pv42FLX/U
THsBv1x1EDJOPvr2joQ57BsTSyqbWkvbXN5ejA1giReHE+GO5wmuajFp2pzzzV9g
GHsgUs47k1C3MxE8m4kZleevHTqLenLHTBPs2noNZQzkv1iomcdknB9XQjaPsN6f
Vixs1iAKGBNOVu035vvzhmoKyzqS/e8R2pdDNKN94MeGOhtuUBe4UyzjRQNKV8MP
m9twpEHeiosxJ2LhAlEjIiV5PeAl3aQMomB0Ep1rlyLPav/oyH7L3XO4nJy7gZSA
fWSiPA6orI5oZVaOlVTOnXru1B94USbxG85pBReFf6ybqg3YUjudzqqSVtg2fYf+
fU2bpK5U3BcPe8b+BT8EBWcRuGvbpmpsfu/nlHj4UqGVHYueeJy5sUbmDdknjLn3
QvLvBlBn4cP2gNSEpVOk7NNXr59ayBh9+znucUqVJ+CAi9PT6eRt1HxOM3/x8VQ7
j6cNwXqyOydu5sdbLl/1t/k380D4wQ0yEfv9OxUuodJjZwcWYLF8LpnVr6Sc9EHH
2fLqwieir3i1aN9XyVDj
=GJKN
-----END PGP SIGNATURE-----

--=-i0nm3FHJuOkZWUmzCwo1--
