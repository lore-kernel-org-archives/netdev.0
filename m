From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v4 05/16] IB/pvrdma: Add functions for Verbs support
Date: Thu, 15 Sep 2016 10:15:16 +0300
Message-ID: <20160915071516.GQ26069@leon.nu>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-6-git-send-email-aditr@vmware.com>
 <20160914124947.GA14616@infradead.org>
 <BLUPR0501MB836AB8BF5108322033C5DD6C5F00@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160915061537.GC4869@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="2D20dG0OqTzqkNh7"
Cc: Adit Ranadive <aditr@vmware.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160915061537.GC4869@infradead.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2D20dG0OqTzqkNh7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 14, 2016 at 11:15:37PM -0700, Christoph Hellwig wrote:
> On Thu, Sep 15, 2016 at 12:10:10AM +0000, Adit Ranadive wrote:
> > On Wed, Sep 14, 2016 at 05:49:50 -0700 Christoph Hellwig wrote:
> > > > +	props->max_fmr = dev->dsr->caps.max_fmr;
> > > > +	props->max_map_per_fmr = dev->dsr->caps.max_map_per_fmr;
> > >
> > > Please don't add FMR support to any new drivers.
> >
> > We don't and our device reports these as 0. If you want me to more explicit I
> > can remove the zero'd out properties.
>
> Oh, ok.  I'll withdraw my comment then.

I would suggest to remove zero assignments to struct which is zero from
the beginning. It will eliminate the confusions.

Thanks

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--2D20dG0OqTzqkNh7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX2kqEAAoJEORje4g2clin2kUQAJyxl81bO5ry5w41MxzvdezM
azeczl/QTUnkUMItIHBMD6MWWhRjKg0BgZrg9+KOYnnmO5l9ZzFt6KPCNOiO8DbN
Up6eOaLHtfDoMzWR0Cw6yFL6PfXZXqBVCs30j6XpoD6LNTnQXTroLRHonwqJ+T1+
2Xnu9rLIc/N6KB8RW3aSpI7ESYfJkIxxKFk3K0srxSOKSC9cXuIkfWSw20vNGNSJ
Ixk12SlWUe/W/YVmD6HS+iVNXoGOAoZt4Pu5DdaZZyuhCGeV7wiIuwS1SIU3DrLW
7NErMwasQkAwrhnrORc0mor8qHPBSxZDeivfhEMryYsM2j8GCGuHIj+vaKeq85PI
pCCr2N3DxPY8yro8GDX2wlM618FTtRypoQAJwaspAVQgz5PEbedtucXLGsRA/dkW
Nm65vwzQU95EsX8ObvyIPn9bmHhOiJUzbCJHQSTpD769LA8sjgjnhf6RvCLnUPsT
dn+ixYaIYLKRuwecP4lDmnGSh5pBkHMUUgSvDa9HpffLjEAhUUEIGt6MPOtlK5KH
JdUyu+lGeJ8TOXraXaxQoPEiC7DRoNYuNYKrRlipzVRxNaAULliKOquuyglffcDc
JDI6KVQXh/NxZ9iu/z/f2JawKoo3fc3JEhHXVvOWwMnMB8dRCYk6aHCL1Kl7+C2/
wWrodwgKQVCKCWcmEfvD
=tL4W
-----END PGP SIGNATURE-----

--2D20dG0OqTzqkNh7--
