From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 13 Sep 2016 13:19:12 +0300
Message-ID: <20160913101912.GU8812@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <20160912180508.GI5843@obsidianresearch.com>
 <DM3PR1101MB1181DF570D4F01A0CEB1CFC7E2FE0@DM3PR1101MB1181.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="LtN0I0gXzHUftVCi"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <DM3PR1101MB1181DF570D4F01A0CEB1CFC7E2FE0-xYdf0wd+uoGW1Nawvih6nR68uu4wjhmwnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--LtN0I0gXzHUftVCi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 13, 2016 at 08:44:06AM +0000, Ram Amrani wrote:
> Hi Jason,
> I see that "include/uapi/rdma" contains API that is common.
> The qedr_user.h, that I assume you are referring to, is a qedr specific API.
> For example, we issue the ib_copy_to_udata() on structures defined in the file.
> So per my understanding it is in place.

1. It will be great if you avoid from top-posting.
2. In the near future, these custom UAPI header files will be placed
under include/uapi/rdma/provider/.

>
> Thanks,
> Ram
>
>
> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]
> Sent: Monday, September 12, 2016 9:05 PM
> To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
> Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>; Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
>
> On Mon, Sep 12, 2016 at 07:07:34PM +0300, Ram Amrani wrote:
> >  drivers/infiniband/hw/qedr/main.c              |  907 ++++++
> >  drivers/infiniband/hw/qedr/qedr.h              |  494 ++++
> >  drivers/infiniband/hw/qedr/qedr_cm.c           |  626 +++++
> >  drivers/infiniband/hw/qedr/qedr_cm.h           |   61 +
> >  drivers/infiniband/hw/qedr/qedr_hsi.h          |   56 +
> >  drivers/infiniband/hw/qedr/qedr_hsi_rdma.h     |  748 +++++
> >  drivers/infiniband/hw/qedr/qedr_user.h         |   80 +
>
> We are requiring new uAPI headers are placed under include/uapi/rdma/, please coordinate with Leon on the path.
>
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--LtN0I0gXzHUftVCi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX19KgAAoJEORje4g2clinpLgQAJD8vx+mbpIBBHa+X515XrQD
33B3pfwaRKEwO3bItE8Y5+ApcT6cLjCaBwhEaIjXseHc1GbgGtFGUzKWz3DrlYeF
35o9RyJx/hFuRdkUEBbsWRqQ7lC+9Ysl61NB/nGS/gjMIdOopxDktjHuc2wuZjSu
zi5NVDrYGG8HU86e5c5L6PTywYpg9JbXEilQKTO6+Pi/6qzvhZZoE9UPY8WZekpe
dP4Qi7S4RgS/Pv9MGOXCwFGGzp+ST5b0yaDN0VzLg+YYRCYFkyaeZgGpbJwfScoT
BzBFzeNsxWz3cFXKFx+XOJGZqZZppBIYXMa4AuQ6kERla8NkapMxQA3IAkQDgJly
lPi/Db8vinHucKB/U7eDm2MKwpP63B6vLq8Cl6eI4LYErSA8c+sImPc2joIZvCze
iieTePZM/3m26j5y5gW5mn6Pj949WH6d3XR3gpa9DFsW/2uX4UVA8s9292yy5zzn
KL0D3QKOVZu0oRCfp9jR8/E3dSXzj9Db/A/0gTRFcBmX+yNlmKxkPxvsWgT0EA6N
GNTH6/FDBKXyO8VjnvsZga1JIwpDyhvnLut3/4ady785p0+uXNgwZBqKbCOkIT1t
ZCrc8LT7TW+9ImSYfXiKNembigi3YVRLmnG0gDwgmqV8AG7jVdLfT7ATZsxxGm2x
96dAQFUvbxrN350Ba9d0
=mKgn
-----END PGP SIGNATURE-----

--LtN0I0gXzHUftVCi--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
