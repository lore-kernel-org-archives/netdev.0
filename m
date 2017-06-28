From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Wed, 28 Jun 2017 07:33:37 +0300
Message-ID: <20170628043337.GX1248@mtr-leonro.local>
References: <20170626182924.GB16026@obsidianresearch.com>
 <20170626192103.GH1248@mtr-leonro.local>
 <20170626203610.GB17892@obsidianresearch.com>
 <20170627040604.GI1248@mtr-leonro.local>
 <20170627092129.GR1248@mtr-leonro.local>
 <20170627164150.GA4288@obsidianresearch.com>
 <20170627173301.GS1248@mtr-leonro.local>
 <20170627173735.GA5162@obsidianresearch.com>
 <20170627174615.GV1248@mtr-leonro.local>
 <20170627151859.524d1079@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="dZRDC+ooC0woGCz3"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170627151859.524d1079@xeon-e3>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--dZRDC+ooC0woGCz3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 27, 2017 at 03:18:59PM -0700, Stephen Hemminger wrote:
> On Tue, 27 Jun 2017 20:46:15 +0300
> Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> > On Tue, Jun 27, 2017 at 11:37:35AM -0600, Jason Gunthorpe wrote:
> > > On Tue, Jun 27, 2017 at 08:33:01PM +0300, Leon Romanovsky wrote:
> > >
> > > > My initial plan was to put all parsers under their respective names, in
> > > > the similar way as I did for caps: $ rdma dev show mlx5_4 caps
> > >
> > > I think you should have a useful summary display similar to 'ip a' and
> > > other commands.
> > >
> > > guid(s), subnet prefix or default gid for IB, lid/lmc, link state,
> > > speed, mtu, pkeys protocol(s)
> >
> > It will, but before I would like to see this tool be a part of
> > iproute2, so other people will be able to extend it in addition
> > to me.
> >
> > Are you fine with the proposed code?
> >
>
> Output formats need to be nailed down. The output of iproute2 commands is almost
> like an ABI. Users build scripts to parse it (whether that is a great idea or not
> is debateable, it mostly shows the weakness in programatic API's). Therefore fully
> changing output formats in later revisions is likely to get users upset.
>
> The first version doesn't have to be perfect, just close to the overall goal
> of what is planned.

In this version, I'm going to use arrays without indexes, because I prefer
to expose the bare minimum from the kernel, which is RDMA netlink. After
everything else is settled, I'll move those defines to UAPI and reuse them
in rdmatool.

I'll send new version with -d/--details flag and enrich minimal summary.
It won't include anything related to tables gids, pkey yet.

Thanks


--dZRDC+ooC0woGCz3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllTMaEACgkQ5GN7iDZy
WKeYcxAAoI8BpuZUGxUbSWcZIjipzBjPRsQOKbnKkkQ+40KE5hXnZCMAQxHy3bvl
ZqNOPBmZz/LJbLdSYojAOZxPlMvZ0ZUH8qxRGq0VRMkaXAhyhSISpBor0VpjeBqz
GBZ/61BcX18hI6CwFlyW/ULfwgMZfhZuXFtg1CfOXh5sZ/ogcUJ26pCMvXxlAiLD
JNbGod+b4JfutFWdDBqbKpbSDMQd+CGpH5T79wQn6D2c498sw7AcNYx6CBxP6L5g
OQSUii4pYHvRDveAz66rQvd6rjdhfnvARRGnXpHhDGHODSQsP7gNmYijLdoNRb5j
zANNAcdFr3vuSjnqWoXtF5jOFJlBw759W2Q/M86o5qN/vOT3mQa8c5py/SQvWQz2
2ON6ghpUPBKs9F6PrX8H9IMfL0Q9o0fT+ea0IRCVDy6ndG/59fJQkY/kKbIWiazs
gEWuPRdXOCI2x7VoN7pX/GGskW89liBzqHNFZBRzx19eJ6g5hsTFnT4IzoKSpVeo
8I9UrDwT9PlC9ReE7CaYe/DcQ4spNSdaYSIse2W1oZqfp3ij2qFYmnAZCviqsdZu
fcwASBR2KJ45j6Gks2bz42UtgXPYd2EJSZ5R2W0r+BOfDUkNgyOkdetPYAQ1Nh8Y
kqSO89z9neuixzj5/lHkTIu0qkCGn0V0EGEl1/alcb2Llve2ZQQ=
=64Sr
-----END PGP SIGNATURE-----

--dZRDC+ooC0woGCz3--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
