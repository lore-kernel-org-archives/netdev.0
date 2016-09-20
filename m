From: "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC v2 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 20 Sep 2016 13:33:25 +0000
Message-ID: <CY1PR0701MB133773B2CB71FA6362CADCFF90F70@CY1PR0701MB1337.namprd07.prod.outlook.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <20160920121151.GK26673@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Borundia, Rajesh" <Rajesh.Borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "Amrani, Ram" <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160920121151.GK26673-2ukJVAZIZ/Y@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Tue, Sep 20, 2016 at 01:35:52PM +0300, Ram Amrani wrote:
...
> > The series adds on top of RFC v1:
> > * a check for all drivers that IB_ACCESS_MW_BIND isn't set for ib_get_d=
ma_mr
> > * relocation of qedr user API to include/rdma/uapi/providers/
> > * removal of qedr_devlist_local
> > * fixed error handling in qedr_alloc_resources()
> > * configuration of PBL in ib_map_mr_sg() driver implementation,
> >   rather than post_send's IB_WR_REG_MR
> > * misc.: placed code in proper patch, fixed a few comments,
> >   removed extra parentheses
> >
> > Thanks for everyone which pointed out problems in the driver.
> >
> > Any review/comment is appreciated.
>=20
> Very nice,
> Any reason why didn't you drop debug module parameter and decided to
> mimic already available kernel core functionality?
>=20
> You got technical explanations why it is bad idea to use it. If you need =
additional
> voices
> to support my claims, you will find them in thread about VERBOSE flag and=
 responses
> from
> Doug, and Dennis.
>=20
> Thanks
Hi Leon,
The RFC cover letter lists what has been addressed. Debug printouts are not=
 addressed in V2 as the discussion on that topic is not concluded (more tho=
ughts from us on debug printouts incoming on the thread). There were many c=
omments to V1 which are not relevant to debug printouts which are addressed=
 by V2. We are requesting further comment, hence RFC V2. Rest assured, if i=
t is the final opinion in the relevant discussion that pr_debug is the way =
to go, that's what we'll do.
Thanks,
Ariel
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
