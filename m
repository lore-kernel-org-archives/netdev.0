From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Re: 3.0.12 - unregister_pernet_gen_subsys hogging whole system
Date: Thu, 22 Dec 2011 22:52:46 +0100
Message-ID: <20111222215246.GA2694@nik-comp.lan>
References: <20111222151908.GA11020@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Cc: stable@kernel.org, netdev@vger.kernel.org
To: linux-kernel mlist <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111222151908.GA11020@pcnci.linuxbox.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> after updating one of our servers to 3.0.12 kernel, it became painfully s=
low (actually
> it's almost unusable).
>=20
> trying perf top, I see following:
>=20
>             27465.00 - 59.8% : unregister_pernet_gen_subsys
>              3144.00 -  6.8% : __start_notes
>              1211.00 -  2.6% : swiotlb_sync_sg
>              1155.00 -  2.5% : swiotlb_unmap_sg_attrs
>               621.00 -  1.4% : pci_pm_init
>               565.00 -  1.2% : swiotlb_map_sg_attrs
>               503.00 -  1.1% : cgroup_attach_task

crap, I was using too old perf binary - that might be reason why I wasn't a=
ble
to find any evidence of unregister_pernet_gen_subsys for 3.x kernels :)
I switched to 3.0.13 now (and actual perf) and it seems better..
Should the problem reappear, I'll report it..
sorry for the fuzz..
n.


>=20
> I wasn't too successfull trying to find something related, so I'd like to=
 ask,
> which subsystem might be calling unregister_pernet_gen_subsys and why?
> I guess this is certaingly a bug... Could somebody please have a look at =
this?
> I'll provide all debugging information I can if needed..
>=20
> thanks a lot in advance
>=20
> with best regards
>=20
> nik
>=20
> --=20
> -------------------------------------
> Ing. Nikola CIPRICH
> LinuxBox.cz, s.r.o.
> 28. rijna 168, 709 01 Ostrava
>=20
> tel.:   +420 596 603 142
> fax:    +420 596 621 273
> mobil:  +420 777 093 799
> www.linuxbox.cz
>=20
> mobil servis: +420 737 238 656
> email servis: servis@linuxbox.cz
> -------------------------------------



--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 01 Ostrava

tel.:   +420 596 603 142
fax:    +420 596 621 273
mobil:  +420 777 093 799

www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk7zpq4ACgkQ3xdJJrLygV5nLQCgzNe8REKERQOqm5Ib1A/1h++j
ccgAoJXmhf3bRgoVy6QCgCtGIMzBQq+2
=cpBN
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
