From: "Amrani, Ram" <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH net 1/3] qed: Release CQ resource under lock on failure
Date: Thu, 16 Feb 2017 09:19:42 +0000
Message-ID: <SN1PR07MB220798D8643CAE11E17E791CF85A0@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1485292523-8821-1-git-send-email-Yuval.Mintz@cavium.com>
 <1485292523-8821-2-git-send-email-Yuval.Mintz@cavium.com>
 <20170125072426.GA4973@yuval-lap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> The bitmap functions are being used by various bitmaps one of which is th=
e cid.
> The cid code must allocate two consecutive cids. So here the lock is over=
 two calls
> to the bit allocating call.
>=20
> I am planning to recode the cid to use one bit instead of two, this is fu=
rther
> down the list.
>=20
> Thanks for the suggestion,
> Ram


Hi Dave,
The patches should be taken as is.
The improvement suggestion about the (widely used) mechanism is still under=
 consideration
and will surely not be part of 4.10.

Shall I resend V1?

Thanks,
Ram

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
