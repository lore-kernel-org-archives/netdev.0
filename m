From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [for-next 5/6] net/mlx5: Bump driver version
Date: Fri, 26 May 2017 21:10:46 +0300
Message-ID: <20170526181046.GW17751@mtr-leonro.local>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-6-saeedm@mellanox.com>
 <3733699c-480b-a1aa-14e1-4f27f86cfead@intel.com>
 <CALzJLG_ha-XiPAMnoKrUgm_EwPx2yH0T2y4EBRfrWNYSZi1cTg@mail.gmail.com>
 <ee23ad82-4a2e-8546-d41b-11f979b127bb@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Hw0FrjWlp+qkNlJP"
Cc: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ee23ad82-4a2e-8546-d41b-11f979b127bb-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Hw0FrjWlp+qkNlJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 26, 2017 at 12:55:22PM -0400, Dennis Dalessandro wrote:
> On 5/26/2017 12:35 PM, Saeed Mahameed wrote:
> > On Fri, May 26, 2017 at 3:56 PM, Dennis Dalessandro
> > <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> > > On 5/23/2017 7:44 AM, Saeed Mahameed wrote:
>
> > Anyway i don't think we are going to change this frequently or even use it.
>
> > But if you are that much against touching this ethtool field, why
> > don't you just jump into the mud and remove it from the tree, I
> > imagine it is really hard for you to watch for patches doing this and
> > nack them on the list.
>
> I have no interest in policing that. I complained about the other driver
> because I know patches like that were NAKed by Greg KH in the past (ours).
> I'd rather not see the rdma subsystem keep making the same mistakes is all.
> We want to improve our standing in the community after all. As I said I'm
> not personally against it as evidenced by our driver.

I personally would like to see patch which does two things:
1. Removes all these MODULE_VERSIONS
2. Puts some hardcoded value common to kernel, so no user space
application (like modinfo) won't be broken.

>
> > > I realize Dave has already pulled this and I'm not asking for it to be
> > > reverted but maybe some discussion will help guide future patch submissions
> > > which do this stuff.
> > >
> >
> > Sure, although i don't think we are going to use those version fields
> > in the future,
> > please allow me to ask, how do you do your driver versioning ? how do
> > you track things ?
> > and what is your future vision regarding ethool->drv_version ?
>
> That's just the thing, we don't do anything with it either really. I'm
> trying to justify its existence to myself and if you folks had some whiz
> bang idea for a driver version I was interested in hearing what it was.

No, we didn't find any real usage of it too. My attempts raise attention
to that issue in netdev weren't successful, maybe you will have
more luck than me.
https://lkml.org/lkml/2016/7/15/17
https://patchwork.kernel.org/patch/9349357/

Thanks

>
> -Denny
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--Hw0FrjWlp+qkNlJP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkob6YACgkQ5GN7iDZy
WKfePQ//S5IU8cX4X0gQhrNBkAAIOCjtFWyFoS/XwGMlElNtR6OCWUz8FNEyCKDo
ixLVWnPTk5OtEM0gw7ySptVTY5VjUVKZyQJlFjLEkg9x7ZgvszFf7Ljh2JU+a87q
3ztS8MtZHpictH59ost4K+ZSZVPZWOC1VJc/3v/fgzBf9yMj4jFjOjTr6OGbeLjz
8UOQdiy1uPJOM4EgVt2nbYWZPrkrYLc9235MqBKomwpmnptOl3NCsvHQXtcS3UZs
JVZOdIUYFqG1hAC4fUTqYTTdQ0+0KxXdfJE8cdoink+x8AAzp/tXVwVHyucKeg2h
iQEOv35tsOZRAnC9e2QpI+uank+00s2+hAKVvsNGzEklaeGGWQx1+AMhRNnt/4+9
RnL1MLv9kyJxkBG3iIedjWjwMD5fEjyWCVpwCkvfTfK57d+8ThXfLp0v/hxSYN/y
dz21MIOwTRYZzLhODJiAxbhCPb6+37vFxMhKeo708rfgV9Cqd/2xrcECbsBa1DfF
3Ao+E5JFegxV18SkUnmJ0V9SL8Ni2PqAnJOUtLKuPNtfhzGN7SaqGkoNxnzNgphi
98dbFnVddHYgvsIzEbvVEXECkNtYUqafR3eTa/9NLk0QJ5EKt90wq6tEu2TsRGE9
Q5/b40dR0gJEvWvX7PGoIZkvChND/Ygg2GTZwVLHUWabdkphZBU=
=fjh0
-----END PGP SIGNATURE-----

--Hw0FrjWlp+qkNlJP--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
