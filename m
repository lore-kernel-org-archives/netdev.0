From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Wed, 28 Jun 2017 22:11:09 +0300
Message-ID: <20170628191109.GN1248@mtr-leonro.local>
References: <20170626192103.GH1248@mtr-leonro.local>
 <20170626203610.GB17892@obsidianresearch.com>
 <20170627040604.GI1248@mtr-leonro.local>
 <20170627092129.GR1248@mtr-leonro.local>
 <20170627164150.GA4288@obsidianresearch.com>
 <20170627173301.GS1248@mtr-leonro.local>
 <20170627173735.GA5162@obsidianresearch.com>
 <20170627174615.GV1248@mtr-leonro.local>
 <20170627151859.524d1079@xeon-e3>
 <20170628161112.GB28839@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="NILByKcPRZiJ7ENr"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:51860 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751566AbdF1TLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 15:11:16 -0400
Content-Disposition: inline
In-Reply-To: <20170628161112.GB28839@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--NILByKcPRZiJ7ENr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 28, 2017 at 10:11:12AM -0600, Jason Gunthorpe wrote:
> On Tue, Jun 27, 2017 at 03:18:59PM -0700, Stephen Hemminger wrote:
> > On Tue, 27 Jun 2017 20:46:15 +0300
> > Leon Romanovsky <leon@kernel.org> wrote:
> >
> > > On Tue, Jun 27, 2017 at 11:37:35AM -0600, Jason Gunthorpe wrote:
> > > > On Tue, Jun 27, 2017 at 08:33:01PM +0300, Leon Romanovsky wrote:
> > > >
> > > > > My initial plan was to put all parsers under their respective names, in
> > > > > the similar way as I did for caps: $ rdma dev show mlx5_4 caps
> > > >
> > > > I think you should have a useful summary display similar to 'ip a' and
> > > > other commands.
> > > >
> > > > guid(s), subnet prefix or default gid for IB, lid/lmc, link state,
> > > > speed, mtu, pkeys protocol(s)
> > >
> > > It will, but before I would like to see this tool be a part of
> > > iproute2, so other people will be able to extend it in addition
> > > to me.
> > >
> > > Are you fine with the proposed code?
> > >
> >
> > Output formats need to be nailed down. The output of iproute2 commands is almost
> > like an ABI. Users build scripts to parse it (whether that is a great idea or not
> > is debateable, it mostly shows the weakness in programatic API's). Therefore fully
> > changing output formats in later revisions is likely to get users upset.
>
> It would be nice to see an example of what the completed command
> should output to make judgements on the format.. Going bit by bit
> doesn't really give a full picture, IHO.

Bit by bit expansion allow easily control of what is needed. Mostly,
those full examples have nothing close to real use case.

>
> Jason

--NILByKcPRZiJ7ENr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllT/00ACgkQ5GN7iDZy
WKeANRAAzjACk0f57EANRv/McGfxg3ynKVC41bk/YWAPjH3Be3+cfoXM+VCju71R
SsDXyHu7R1fMob/gYoxFuzTdSF3ERJwzupnQWZJh99Sg2m1JoL6mqqTq0CFUgNkL
0pQSbHFBi1HCc3sKqtBKxtBJIdK0F8dMtgubtv8iMRSzY57WKRXcZ109zPgLL2zB
1oBZs+KZE56/SloqMhMp0YCR48JMOIz3Ztz2H8f9wcLy6ZWIlYoAf/tkizRkCEb+
yuIYjLfE96jyOdXRwgiwpbEmBHa2J4wd2vaPEQyf7Yr4XuNRU2uCtV895dz5qNqc
RvedFyaCkygdMku4BBFBNpxnTqMZLkV9AmTUXiVuOkZkdtFVtrLTBnudyUzEofaz
de49uOWUaxg5EgyOgnmU/4iUR3uZuEjLCJc1gy2zE3kU/JAE+1A5M2gNFnz40NJt
3wMeMhZeps7y6XfOFpjdCzZpixQsO6KFOBSTST8I6H428/Qb4P3kvmYOUc8wNMDf
6eeEBYcjJu0acFP58xHs1rsVg1JdfjK+6m+hp4GRCvAMLCCKP0lnd7/g53e20SqI
9SCslBH67VDNeVKt7WYw11IEmyD/bboOs2j5XT8QfngVgzTOoLyGo2HeWPtzdEMi
Ykstx8MgjpmrZWlpydSml7foRdLLa57r3oxiTAYaznaLJ00YxRI=
=GkpH
-----END PGP SIGNATURE-----

--NILByKcPRZiJ7ENr--
