From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 13 Sep 2016 09:05:45 +0300
Message-ID: <20160913060545.GN8812@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <20160912163928.GK8812@leon.nu>
 <CAG53R5UqF21z34jB2HJCTXU8w3Kbj_Jon=wBAoO5tYSqbD1f6g@mail.gmail.com>
 <CY4PR11MB17202A542AC07CBA4A65E93697FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7VkxxUl3xUvPtoxk"
Cc: Parav Pandit <pandit.parav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CY4PR11MB17202A542AC07CBA4A65E93697FF0-JNf6+SjKdlG0ooKL/ADlEpPPoyLQLiKMvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--7VkxxUl3xUvPtoxk
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 12, 2016 at 05:39:35PM +0000, Yuval Mintz wrote:
> >>>=C2=A0 include/linux/qed/common_hsi.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=
=A0=C2=A0 1 +
> >>>=C2=A0 include/linux/qed/qed_if.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 |=C2=A0=C2=A0=C2=A0 9 +-
> >>>=C2=A0 include/linux/qed/qed_ll2_if.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 140=
 +
> >>>=C2=A0 include/linux/qed/qed_roce_if.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 604 ++=
++
> >>>=C2=A0 include/linux/qed/qede_roce.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=
=A0=C2=A0 88 +
> >>=C2=A0> include/linux/qed/rdma_common.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0=
=C2=A0 1 +
> >>
> >> Something not directly related to your patches, but they brought my
> >> attention to the fact that all these new (and old) rdma<->net devices
> >> are polluting include/linux
> >>
> > ocrdma driver includes be_roce.h located in net/ethernet/emulex/benet
> > location instead of include/linux/.
> > This file helps to bind rdma to net device or underlying hw device.
>
> > May be similar change can be done for rest of the drivers for
> > rdma<-->net devices?
>
> By adding explicit inclusion paths in the Makefile, a la
> ccflags-y :=3D -Idrivers/net/ethernet/emulex/benet   ?
>
> While this might work, I personally dislike it as I find it
> counter-intuitive when going over the code -
> I don't expect driver to locally modify the inclusion path.
> Besides, we're going to [eventually] a whole suite of drivers based
> on the qed module, some of which would reside under drivers/scsi;
> Not sure it's best to have 3 or 4 different drivers privately include the
> same directory under a different subsystem.

I agree with you that orcdma's way can be valuable for small drivers.

Orcmda has small shared headers set and doesn't need to change them rapidly
to support different devices.

I thought to place them in similar directory to include/soc/* and remove
=66rom include/linux/. We have include/rdma/ and it looks like a good
candidate.

>
> >> Filtered output:
> >> =E2=9E=9C=C2=A0 linux-rdma git:(topic/fixes-for-4.8-2) ls -dl include/=
linux/*/
> >> drwxrwxr-x=C2=A0 2 leonro leonro=C2=A0 4096 Aug 30 16:27 include/linux=
/hsi/
> >> drwxrwxr-x=C2=A0 2 leonro leonro=C2=A0 4096 Sep 12 19:08 include/linux=
/mlx4/
> >> drwxrwxr-x=C2=A0 2 leonro leonro=C2=A0 4096 Sep=C2=A0 7 15:31 include/=
linux/mlx5/
> >> drwxrwxr-x=C2=A0 2 leonro leonro=C2=A0 4096 Sep=C2=A0 8 17:46 include/=
linux/qed/
> >>
> >> Is this the right place for them?
> >
> > Thanks
>

--7VkxxUl3xUvPtoxk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX15c5AAoJEORje4g2clinSJkP/2F67ghkBA2xeXOLuMoBb3Nc
ue+MAHB8ACDfcIUhpJUkZFU0jqMUi3j0Yc0itux7mGnwEIlkBc6dTWMKQG6l3zcF
bonsUv4B0m6U8//92R/1hkIBhiXGmwkO22tzWz469rodIrvM5I14btumHpvKrpcj
DUk/WrTh37j+SNvViZ/xjlJUJN6H7t38Wp+arDCay8VBmElvRYejQEsSdhn9SeEi
tay7USTmljdh6lCUJugM7usRIcxXjGXcIxu/JZoU5BmBMJvleIVK09TkyppY7HHD
bRizp0OztjSBwW7gKRwfYZeqloo2/RvhIk+FKS9L9bqHMnqKHsQ9i9CnPbgMd9Lh
i03fSn4wPt24NBY8cyqumfTJyKCn47KKkAXCzVzRJFbAifEnNZpQik4fl+axZPuv
0m5avLLVdXyC+QI3KESuongZVbVHYQ9GFPHqkV76BW9Jg14V2DCkNv6tQmCdiC8X
WQwRAbcJZWDHtBsuiww5oHidSGn+pYyhpD+FTBvEkdI0tlmay+RM68jsfdgb4alN
ixMMGUoYOE8/BqaKyITRJDcMDCKfU0tXkg6WfHmHfpnVHjjm08JcHx6tAclDNBnB
Xliwl+qg6hzpypUP9EweWz4U7RTWpE+AYa1la+wqTiyNRuDckMdl+Bzs8AEIncW9
Ap49lZ2YRAM9bb2cnWrw
=ASWE
-----END PGP SIGNATURE-----

--7VkxxUl3xUvPtoxk--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
