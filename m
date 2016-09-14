From: "Amrani, Ram" <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Wed, 14 Sep 2016 14:44:47 +0000
Message-ID: <SN1PR07MB2207486633D88B5C65D547F9F8F10@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <20160912180508.GI5843@obsidianresearch.com>
 <DM3PR1101MB1181DF570D4F01A0CEB1CFC7E2FE0@DM3PR1101MB1181.namprd11.prod.outlook.com>
 <20160913154000.GA25878@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160913154000.GA25878-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Anything that is used with copy_to/from_user, ib_copy_to/from_udata,=20
> etc, etc must be in a include/uapi header.
>=20
> Any constant you might want to copy into your userspace provider must=20
> be in include/uapi.
>=20
I understand you mean something like https://www.spinics.net/lists/linux-rd=
ma/msg40414.html ([RFC rdma-next 0/3] Move mlx5 vendor specific to UAPI dir=
ectory)

> Avoid copying headers in your user space and use the standard kernel=20
> names to access your driver's uapi.
So the user library should be able to compile against these headers in thei=
r location and not hold identical copies.
What do you mean by "standard kernel names"?

Thanks,
Ram

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
