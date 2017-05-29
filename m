From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [for-next 5/6] net/mlx5: Bump driver version
Date: Mon, 29 May 2017 08:47:55 +0300
Message-ID: <20170529054755.GY17751@mtr-leonro.local>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-6-saeedm@mellanox.com>
 <3733699c-480b-a1aa-14e1-4f27f86cfead@intel.com>
 <CALzJLG_ha-XiPAMnoKrUgm_EwPx2yH0T2y4EBRfrWNYSZi1cTg@mail.gmail.com>
 <ee23ad82-4a2e-8546-d41b-11f979b127bb@intel.com>
 <20170526145318.7fd8c8e2@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="nDmTXYS4kVhtHHfR"
Cc: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jakub Kicinski <kubakici-5tc4TXWwyLM@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170526145318.7fd8c8e2-68UzVGuGftmUSpRRplVxJ1aTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--nDmTXYS4kVhtHHfR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 26, 2017 at 02:53:18PM -0700, Jakub Kicinski wrote:
> On Fri, 26 May 2017 12:55:22 -0400, Dennis Dalessandro wrote:
> > >> I realize Dave has already pulled this and I'm not asking for it to be
> > >> reverted but maybe some discussion will help guide future patch submissions
> > >> which do this stuff.
> > >>
> > >
> > > Sure, although i don't think we are going to use those version fields
> > > in the future,
> > > please allow me to ask, how do you do your driver versioning ? how do
> > > you track things ?
> > > and what is your future vision regarding ethool->drv_version ?
> >
> > That's just the thing, we don't do anything with it either really. I'm
> > trying to justify its existence to myself and if you folks had some whiz
> > bang idea for a driver version I was interested in hearing what it was.
>
> FWIW I put VERMAGIC_STRING in drv_version:
>
> # ethtool -i p4p1
> driver: nfp
> version: 4.12.0-rc2-perf-00282-gc42dfc79
> ...
>
> I think I got that idea from Felix Fietkau.  The backport-ified version
> of the driver [1] uses git hash and "o-o-t" sting:
>
> # ethtool -i p4p1
> driver: nfp
> version: 49e5c6abf5b2 (o-o-t)
> ...
>
> So it's pretty easy to tell which driver the customer is using.  I
> could probably throw in the output of $(git rev-list --count HEAD) to
> have an automatic monotonically increasing "version" when built
> out-of-tree, hm...

Thanks for the pointer. I'll try to evaluate it.

>
> [1] https://github.com/Netronome/nfp-drv-kmods

--nDmTXYS4kVhtHHfR
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkrtgsACgkQ5GN7iDZy
WKfGZBAAuSAzi2GN0WZtaw73K+0ZH5+WnAipBSRJHWzDeRUHppXHlzVta6Q97Qf9
8PTw8SRmGKOvTlQYQ7XeXuj1RZs0B6NP4MPsMa4ap6hjchQeblo5p1a+2ceQObsz
E5ml9Cu+mowwKGL/SrkTea8QvJAnmdKn41pEBZldonL/fw1/81MEq/cjKABhK0jD
rnEi/sMApf+60F0bpzIRvBHFp8WDimC2qJ5ykbLo+rcFQEdKZkCxD7q9PnqOBmEK
Z+4IAoxXAe7LKEjLHbzlcNP9664XtftK4YnRflywoGktSG8gK6XZnGJC8U7cvcPO
h4qLFQf3BYpl+dyoIdSPLOP8fm9rUblYKCmKbQ+rnF9BWnxYhFl5DRmXXroBBdWQ
HSuwEbBrG9ARrlMAcgEfg9J4GelE4iGSajCXVmpyrtzVFlEJyjN01EVKny9oLafP
lQod4946McUpa+0uXEO/6LIMF38guV5EV/+hSbbvOUJibESo8nPFl+PORY7bi/Zk
lNsVm6PSibT7Mn5h8QPqBrlhLs+GwVoI3ETWPC7M0gKgdYq5ZmsgN+8MQs/5cBjC
1xckT8HebhR2uFT9zUVo/yoM++5qOyEbbbN+elhFbLbkT6LZzhuqUQ+jdMxpGxIN
mU6naHXlTuKoySDM1pBrcUsZR4DwwyAvjqrnsMAfGt3mm6EAE/s=
=Ftk/
-----END PGP SIGNATURE-----

--nDmTXYS4kVhtHHfR--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
