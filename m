From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Tue, 10 Jan 2017 10:14:02 +0200
Message-ID: <20170110081402.GH7218@mtr-leonro.local>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20170109075104.GV15685@mtr-leonro.local>
 <20170110033954.GA53664@knc-06.sc.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="MAH+hnPXVZWQ5cD/"
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170110033954.GA53664-wPcXA7LoDC+1XWohqUldA0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--MAH+hnPXVZWQ5cD/
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 09, 2017 at 07:39:54PM -0800, Vishwanathapura, Niranjana wrote:
> On Mon, Jan 09, 2017 at 09:51:04AM +0200, Leon Romanovsky wrote:
> > On Thu, Dec 15, 2016 at 11:28:06AM -0500, Doug Ledford wrote:
> > > On 12/15/2016 9:52 AM, ira.weiny wrote:
> > >
> > > 2) With more than 60% of the code being MAD related, and another
> > > significant chunk being hfi related, and only a minor bit (20% maybe?)
> > > being net related,
> >
> > Hi Doug and Ira,
> >
> > I may admit that I didn't read the code very deep, but from brief
> > overview, I didn't find support for the claim the "60% code is MAD rela=
ted".
> > It looks like the opposite thing will be more accurate.
> >
> > Can you help me to understand this claim? How did you come to this
> > conclusion?
> >
> > Thanks
>
> Hi Leon,
>
> Here is the breakdown of patches based on functionality.

Hi Niranjana,
Thank you for breakdown, it helped a lot.

> In this series, patches #3..#8 compose hfi_vnic driver. In that, patches =
#4,
> #7 and #8 are MAD focused (interfacing with MAD agent and handling MAD
> packets).

Patch #3 is net device with all goodies from net stack.
https://patchwork.kernel.org/patch/9475639/
Patch #4 has one IB MAD related struct, all other things are specific to
OFA and HFI declarations.
https://patchwork.kernel.org/patch/9475653/
Patch #7 continues to implement agnostic to IB MAD net device.
https://patchwork.kernel.org/patch/9475641/
Patch #8 is without doubts, MAD related.
https://patchwork.kernel.org/patch/9475651/

Let's put aside patch #8, in such case, the proposed code won't need IB/cor=
e at
all and will look exactly like many other net drivers which encapsulate/dec=
apsulate
packets.


> Patch #6 and half of #3 (_encap.c/h) are OPA encapsulation related. Patch=
 #5
> is netdev statistic related (which includes statistics MAD definitions).
> So, only part of patch #3 (_netdev.c and _ethtool.c) deals with interfaci=
ng
> with netstack.
> Those percentage numbers are based on actual lines of code in these patch=
es
> (files).
>
> We are also looking into Jason=E2=80=99s suggestion to make hfi_vnic inte=
rface to
> the bottom driver a generic interface. This will include moving some of t=
he
> netstack interfacing to the bottom hfi1 driver.

Great, do you have rough estimation when will it be posted on the ML?

Thanks

>
> Niranjana
>

--MAH+hnPXVZWQ5cD/
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh0l8oACgkQ5GN7iDZy
WKdRJBAAnUAj+2E8UZ9adfL9PQkOPC4OPXaRAUQmtKSjKfDm8v8KFUvPSsfO0SMB
CVzi9hqTDGx/QU6yNOpcFvixy4L+wQqySSyEhpwCooF7FqQ37hNVb2aaO9SH0cDW
gByMmeU1Dg0kqAgQP8avZZAKhP573oEgd/IiOIWmYmDRmSIZ5z2nIpiWOl0wmSzK
PzywwA2Ndi2yO1QqcScHW4H+OMDPmowFS4CNw3CkzIp6CIZgjXQ9oFpU/v4LkF+S
039IgC24FUexEpLBxL0hFdLr7SfHHdrVuWLeU2tQk8JOXBSJ+344xlm9kSWRbqWn
GMWWTqZZqJTDPdM5/+OJsh/01lsWrFgzjzxS000xL42zdGfyl6zRSPZYt6EpSaAX
6O4ZtTUizy+gPBYPzqG6sxGfc2RhQmVTwdAaqRGCNqHdTnvwKjRY1hUW6N+0yFOR
eF7lK3jEP13qEU+pg/z+BlikA+kJjTlMwZBUW+6ogEnei0H0KGUtcypMNlSqJ5jK
MNwXkM/ZlwqG1lvkw5UUfmhv+xLn7uHuHEnri8yOwt0BvNRk6ft3ftxxmkflzyOj
mDNTCahlqaw0Og+6nROyyU+Skey4EevYK5wr9WWlqG9M1lW/u8N21uifEXKqCC4J
WBzIUZ73SXXLTdxFsGozUYj1EVoJDzO/MPHIfbjOiaZeaSAJDTU=
=/bB4
-----END PGP SIGNATURE-----

--MAH+hnPXVZWQ5cD/--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
