From: Leon Romanovsky <leon@kernel.org>
Subject: Re: export pcie_flr and remove copies of it in drivers V2
Date: Wed, 19 Apr 2017 08:37:37 +0300
Message-ID: <20170419053737.GG14088@mtr-leonro.local>
References: <20170414191131.14286-1-hch@lst.de>
 <20170418183612.GC25295@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="R6sEYoIZpp9JErk7"
Cc: Christoph Hellwig <hch@lst.de>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Giovanni Cabiddu <giovanni.cabiddu@intel.com>,
        Salvatore Benedetto <salvatore.benedetto@intel.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        linux-pci@vger.kernel.org, qat-linux@intel.com,
        linux-crypto@vger.kernel.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:39156 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759802AbdDSFhX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 01:37:23 -0400
Content-Disposition: inline
In-Reply-To: <20170418183612.GC25295@bhelgaas-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--R6sEYoIZpp9JErk7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 18, 2017 at 01:36:12PM -0500, Bjorn Helgaas wrote:
> On Fri, Apr 14, 2017 at 09:11:24PM +0200, Christoph Hellwig wrote:
> > Hi all,
> >
> > this exports the PCI layer pcie_flr helper, and removes various opencoded
> > copies of it.
> >
> > Changes since V1:
> >  - rebase on top of the pci/virtualization branch
> >  - fixed the probe case in __pci_dev_reset
> >  - added ACKs from Bjorn
>
> Applied the first three patches:
>
>   bc13871ef35a PCI: Export pcie_flr()
>   e641c375d414 PCI: Call pcie_flr() from reset_intel_82599_sfp_virtfn()
>   40e0901ea4bf PCI: Call pcie_flr() from reset_chelsio_generic_dev()
>

Bjorn,

How do you suggest to proceed with other patches? They should be applied
to your tree either, because they depend on "bc13871ef35a PCI: Export
pcie_flr()".

Thanks


> to pci/virtualization for v4.12, thanks!

--R6sEYoIZpp9JErk7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlj296EACgkQ5GN7iDZy
WKc1zQ/7BSIXdJRgJoHCW6mGUOl+O5Yyons+9qhBJmCZl75w+f2mgejIm1nl9r32
2TcWLQful9IsrKUrsoK1205rOmGhjqg6kRMLicHiOYR1B4NOpWji4IA53RJgyGsY
xlvVHwLuZ5Fl4bjnzRlRP701UYzBkeHJSoOf3ZVLNDtRY7ChDAXN6ny94gMFljbb
CCOdY2877CQmzKgYQ39Iwc5wWEurTJ8VQatunjaXtrp2vGFjwqmBzkil06ZQM+QQ
O8v2JufdH1r+RBaSMq8bBGA5iv31VnGXwe7RdC39TWZx8nuffkgyKXDipTx3xjMn
U0RVFLHAdiOt61EKZu62FST1nibHvQRxohMsLSLCarmN1bVOuJtOEmJShukeUqPS
afDWl64jXxcgp60wvgakc/P0XDxnqQB3VMjABassA7GFTsr/p3b66G3Y19EmfgzF
bBGhweRo3GN1chVBRHB2rY+gtpfg4MNGKvHkmp0+GGLxAIDcSuujSp0l0+JliqzL
tXn/vT3Uy8LFiycpPIpXpNVo14WYJeNbpGCpFy7q+WTA/aqcMv9JoTaM9TuL4yuR
RIUolT9D3OmuBCgA3NfZj5NYLnfoVWuuDr0jgo3PJjhwVnsbFGSrTiy8PDYtn2wo
y7hrrmhWh0953gsI6Aso+MZhBCOmL2RoluGzPOk2qM+xVK4FZ4c=
=uDoL
-----END PGP SIGNATURE-----

--R6sEYoIZpp9JErk7--
