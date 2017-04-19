From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: export pcie_flr and remove copies of it in drivers V2
Date: Wed, 19 Apr 2017 19:40:01 +0300
Message-ID: <20170419164001.GK14088@mtr-leonro.local>
References: <20170414191131.14286-1-hch@lst.de>
 <20170418183612.GC25295@bhelgaas-glaptop.roam.corp.google.com>
 <20170419053737.GG14088@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="YPJ8CVbwFUtL7OFW"
Cc: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Giovanni Cabiddu <giovanni.cabiddu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Salvatore Benedetto <salvatore.benedetto-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Mike Marciniszyn <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Derek Chickles <derek.chickles-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Satanand Burla <satananda.burla-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Felix Manlunas <felix.manlunas-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Raghu Vatsavayi <raghu.vatsavayi-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, qat-linux-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bjorn Helgaas <helgaas-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170419053737.GG14088-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--YPJ8CVbwFUtL7OFW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 19, 2017 at 08:37:37AM +0300, Leon Romanovsky wrote:
> On Tue, Apr 18, 2017 at 01:36:12PM -0500, Bjorn Helgaas wrote:
> > On Fri, Apr 14, 2017 at 09:11:24PM +0200, Christoph Hellwig wrote:
> > > Hi all,
> > >
> > > this exports the PCI layer pcie_flr helper, and removes various opencoded
> > > copies of it.
> > >
> > > Changes since V1:
> > >  - rebase on top of the pci/virtualization branch
> > >  - fixed the probe case in __pci_dev_reset
> > >  - added ACKs from Bjorn
> >
> > Applied the first three patches:
> >
> >   bc13871ef35a PCI: Export pcie_flr()
> >   e641c375d414 PCI: Call pcie_flr() from reset_intel_82599_sfp_virtfn()
> >   40e0901ea4bf PCI: Call pcie_flr() from reset_chelsio_generic_dev()
> >
>
> Bjorn,
>
> How do you suggest to proceed with other patches? They should be applied
> to your tree either, because they depend on "bc13871ef35a PCI: Export
> pcie_flr()".

I finally caught the old emails and found the answer by myself.
http://marc.info/?l=linux-rdma&m=149218545228343&w=2

Thanks

>
> Thanks
>
>
> > to pci/virtualization for v4.12, thanks!



--YPJ8CVbwFUtL7OFW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlj3kuEACgkQ5GN7iDZy
WKe9UA/6A11Wwv/G5iuMDuQlzercr2B7TKJ1/PlU403Xt1MaVTCZEIy6x5JGtJpd
UnEEdKdqLT22FQ2jZfFYnrFb7CX9nKgmMyRj63HWMQVNPGo+88WGBQprgyd/QphS
AUqQuV6cKvqQ/6s1i4gwPwkNzVu9MGNSq7Ud5kkoSxVQN4RDPlBFanL4p5ONd+XP
ShN/NM5dp4unZysx/hg/n1vaB3meZ4iNZf398AruABe5nOdgadxb78AZG75l5PXM
DpDa/91XhazAlmibloBPpdsInv9TaTDJFNwhEaYDBfXnGhhqJmZh/HAaPWY1Kq6C
1C3uuKpUsYYgYWH0w1QGD9dFAu+G0RSYt7qTX2PlJ3KukOecV8HwJt5obOYk/H75
IGHkjBNWe+KiJC5rTpJ9l2eQJWe2CcEBO1AJ0NU7H6E+7GZ6+rE03fS25lQfhIrg
lRHedrj9UkR54zc3nbpyEDPoieek8IuC0yHmnRkrFIhh+/tOf/+NqfwJSh8+v5hP
yOxIqjlb77RZXyXZTYoITcOlnMCh3XE3c4wKNJH0Qjj/12vP650+WnD530hUWins
tH3NqMT7CsNG10DSDchKp/jZf3zRzFX3gTYR+0cPVE69Q24owlje7LdiZCaes9Jr
JpvFXL/dwLks1E0OF+GzSIKDOofaHDvfdVrDZXvg7xbCAUppVm0=
=NaHM
-----END PGP SIGNATURE-----

--YPJ8CVbwFUtL7OFW--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
