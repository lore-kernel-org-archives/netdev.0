From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 20:33:01 +0300
Message-ID: <20170627173301.GS1248@mtr-leonro.local>
References: <20170626182128.24964-1-leon@kernel.org>
 <20170626182128.24964-4-leon@kernel.org>
 <20170626182924.GB16026@obsidianresearch.com>
 <20170626192103.GH1248@mtr-leonro.local>
 <20170626203610.GB17892@obsidianresearch.com>
 <20170627040604.GI1248@mtr-leonro.local>
 <20170627092129.GR1248@mtr-leonro.local>
 <20170627164150.GA4288@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="s33OSBZCP+C8M/FY"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170627164150.GA4288-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--s33OSBZCP+C8M/FY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 27, 2017 at 10:41:50AM -0600, Jason Gunthorpe wrote:
> On Tue, Jun 27, 2017 at 12:21:29PM +0300, Leon Romanovsky wrote:
> > > What will be the output of such command?
> > >  $ rdma dev show mlx5_4
> >
> > ip-like style:
> >
> > $ rdma dev show mlx5_4
> > 5: mlx5_4:
> >     caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
> > $ rdma link show mlx5_3
> > 4/1: mlx5_3/1:
> >     caps: <CM, IP_BASED_GIDS>
>
> I think that is better, maybe it should only show under some kind of
> verbose mode, I don't know, it depends what other stuff ends up being
> displayed..
>
> Are you going to dump the gid table and pkey table too in one of these commands?

My initial plan was to put all parsers under their respective names, in
the similar way as I did for caps: $ rdma dev show mlx5_4 caps

So for large dumps, I'm going to use that technique again and maybe print summary as a default.
For example, for gids, we can print utilization as a summary while whole
table if someone really wants it: $ rdma link show mlx5_4/1 gids <index>

Something like that.

Thanks

>
> Jason

--s33OSBZCP+C8M/FY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllSls0ACgkQ5GN7iDZy
WKca3A//QEvLK9dJ001DAwjDogPRlBs0Fdd25LOl3FhOKV3hwZqLVctLCGrkvJRb
INCzepb3NbUXQvnqjH5kCppRVRtsb4WXtMZ44qgxkXLfMCZUERY6rKdVyc0hkKkp
sjLkVahBDTG99t5Dr4lX46J3pJU3+7LqnjwGt4Mw5FP+MTqDrajaSyYEFJSmbGvA
dA3ONWRlCIBcqEsZ+ChERvdJ38eZaJ6Exe0P+tpnFPBFKy7ajeyy+sS9g4K57pk3
9f5bC8JE8KQDM7+8e0wJiXOWoARG0eQ1cnlT7kmudcu/zohe79tTwiZhBETgigMv
y0L1sm+Ivk18KgsCGuAUnjNGwvOo048zJb6T0wR4zNFaoHL0Q2NfoqiOjul1hSJQ
tPC1Hq4JEFsiARCHvfYqwLpvznGdqViwwTVjgvFqlu6KfxADlPN8267NrdfFQV9O
0kNwzoCFOvwOJ9W8ECrFTyjVTZ2R1kMUU7+Sn4ln1NBimU0o+9DNOpZ3Vf4C5hDK
VT450BYcjkvP/AaD6AAl0hamjxQHFlGHc80S34yN6eRhP2BGd7mXWDT64MdGfcQs
L6uabdJrvgF+ZCnbdDFKN6+Mg6CAPUoh3St7P9IwZUIy/tSlyb4QblYkGWbevRmQ
bFjS/3nnxebevqY0bo6grCOhLehb4mvsjV2il4no3txsTvqIh4o=
=vp6S
-----END PGP SIGNATURE-----

--s33OSBZCP+C8M/FY--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
