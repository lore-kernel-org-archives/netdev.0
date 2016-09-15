From: "Amrani, Ram" <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 09/11] Add LL2 RoCE interface
Date: Thu, 15 Sep 2016 12:07:57 +0000
Message-ID: <SN1PR07MB220746277461969526CFC6C3F8F00@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-10-git-send-email-Ram.Amrani@qlogic.com>
 <20160915102013.GZ26069@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160915102013.GZ26069-2ukJVAZIZ/Y@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > +		DP_ERR(cdev,
> > +		       "QED RoCE set MAC filter failed - roce_info/ll2 NULL\n");
> > +		return -EINVAL;
> > +	}
> > +
> > +	p_ptt =3D qed_ptt_acquire(QED_LEADING_HWFN(cdev));
> > +	if (!p_ptt) {
> > +		DP_ERR(cdev,
> > +		       "qed roce ll2 mac filter set: failed to acquire PTT\n");
> > +		return -EINVAL;
> > +	}
>=20
> Please use single style for your debug prints QED RoCE vs. qed roce.
Sure. This bothers me too. Will fix. Thanks.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
