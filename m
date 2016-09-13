From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 13 Sep 2016 13:39:34 +0300
Message-ID: <20160913103934.GX8812@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <20160912163928.GK8812@leon.nu>
 <CAG53R5UqF21z34jB2HJCTXU8w3Kbj_Jon=wBAoO5tYSqbD1f6g@mail.gmail.com>
 <CY4PR11MB17202A542AC07CBA4A65E93697FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
 <20160913060545.GN8812@leon.nu>
 <BL2PR07MB23064356EA2492675AC980A78DFE0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="jn/MQTzma+jNUHFC"
Cc: Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Parav Pandit <pandit.parav-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23064356EA2492675AC980A78DFE0-I6Fv6QFlT9L2NWYWB7JgfuFPX92sqiQdvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--jn/MQTzma+jNUHFC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 13, 2016 at 06:48:00AM +0000, Mintz, Yuval wrote:
> >> While this might work, I personally dislike it as I find it
> >> counter-intuitive when going over the code -
> >> I don't expect driver to locally modify the inclusion path.
> >> Besides, we're going to [eventually] a whole suite of drivers based
> >> on the qed module, some of which would reside under drivers/scsi;
> >> Not sure it's best to have 3 or 4 different drivers privately include the
> >> same directory under a different subsystem.
>
> > I agree with you that orcdma's way can be valuable for small drivers.
>
> > Orcmda has small shared headers set and doesn't need to change them rapidly
> > to support different devices.
>
> > I thought to place them in similar directory to include/soc/* and remove
> > from include/linux/. We have include/rdma/ and it looks like a good
> > candidate.
>
> I'm perfectly fine with relocating those to a different directory under include/,
> although using 'rdma' doesn't sound like a good fit [as the headers would be
> included by ethernet, scsi and rdma drivers].
> Are there good existing alternatives?

There is nothing that I can name.

>
> Regardless, I don't believe this should be part of the initial submission,
> as it would involve in relocating existing networking headers as well.
> I think we can move those at leisure later on.

Sure, it is good time and context to discuss, but orthogonal to this
submission.

>
> [We're in the middle of transitioning our e-mails from qlogic -> cavium,
> so sorry if things become corrupted]

--jn/MQTzma+jNUHFC
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX19dmAAoJEORje4g2clin1YUP/1+UFUAU2NMfLBomkXOZVWJo
W1YqxjWuqS9Tg9xXuqQDHLZkGRmQAz+bVZMb6bPlgnS1yXgV1nIas4O3kOl7pBCa
pDv36QPwgpdeV4FRa+s37p7bENWJ0zoL67iUSH6dqmAKjwz55f0ipaCw/e5vxgfy
fmS6tAkSlNM3zcxmTr+J7X4pw3MYEqa8wmSxhqjOKMgX+5RPKkCmbPae460PVlyU
oe30U53+Rh4Mo4w3Ke7fSFpaLVTiiQ6j60EUCx/RA9wdYVLYQPmW13ZWv9Uu7kv/
NTg4TPdQYsdOw0CfOgtItwm6gtsURkg4og9EkM2JlAAGZP1R/EPuCFL3zzVf/qUj
41bYRFueEru9VI13NobbpKDgfPFsQShCHTdn5aNdAN4s2VdA9Z5wRzs/xPxxYYev
5aA44KMFDsmzmXq+SVRWV7w6hqoqnWMqgIUI9F+8eJ8Ejl/evtIdRmCHipE7hbVt
y5H3cRyYCYPCTWuQYOc37R4betDrhPh+h3+/0sYwgURMOa0cvPB57JktH1R9+lqG
ajRWWvPK84BW8oDACpVb7UTNv3faLnWCZVbasSRahTXpV4PLsN2TovI0LiRmQBQj
JHKFipgRcooHE8PuDVCxRkvD06a7jdLwstxHhBvUQUD1JQBcgsnjVnjrhHyZ3nw1
fPfpOOk2IxV9nfuxrPLN
=Ghdd
-----END PGP SIGNATURE-----

--jn/MQTzma+jNUHFC--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
