From: "Amrani, Ram" <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC v2 06/12] qedr: Add support for QP verbs
Date: Wed, 21 Sep 2016 14:23:46 +0000
Message-ID: <SN1PR07MB2207B94372F7A910C0E6AF0AF8F60@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <1474367764-9555-7-git-send-email-Ram.Amrani@cavium.com>
 <20160920152849.GD32020@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Borundia, Rajesh" <Rajesh.Borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160920152849.GD32020-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Ugh, each patch keeps adding to this?

The logic in the patch series is to have each patch contain only what is ne=
cessary for the specific functionality it adds.
This made it harder on us to prepare but, IMHO, easier for the reviewer.
If you'd like to have this file in one chunk, I can do this. What do you pr=
efer?



> > +struct qedr_create_qp_ureq {
> > +       u32 qp_handle_hi;
> > +       u32 qp_handle_lo;
> > +
> > +       /* SQ */
> > +       /* user space virtual address of SQ buffer */
> > +       u64 sq_addr;
> > +
> > +       /* length of SQ buffer */
> > +       size_t sq_len;
>=20
> Do not use size_t, that is just asking for 32/64 bit interop problems.

OK

> > +struct qedr_create_qp_uresp {
> > +       u32 qp_id;
> > +       int atomic_supported;
>=20
> int again, etc. You get the idea.

Yeah, I did. Thanks.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
