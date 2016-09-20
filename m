From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v2 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 20 Sep 2016 15:11:51 +0300
Message-ID: <20160920121151.GK26673@leon.nu>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="SCOJXUq1iwCn05li"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1474367764-9555-1-git-send-email-Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--SCOJXUq1iwCn05li
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 20, 2016 at 01:35:52PM +0300, Ram Amrani wrote:
> From: Ram amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>
> This series introduces RoCE RDMA driver for the 579xx RDMA products by Qlogic.
> The RDMA support is added as an additional loadable module (qedr) over the
> Ethernet qede driver.
> The qedr module will support both RoCE and iWarp, although this series only
> adds RoCE support.
> The qed and qede drivers are enhanced with functionality required for RDMA
> support.
>
> Based on net-next 4c73195edbe3a5d7e14ea549bb261cf35c29f0cc.
>
> The series adds on top of RFC v1:
> * a check for all drivers that IB_ACCESS_MW_BIND isn't set for ib_get_dma_mr
> * relocation of qedr user API to include/rdma/uapi/providers/
> * removal of qedr_devlist_local
> * fixed error handling in qedr_alloc_resources()
> * configuration of PBL in ib_map_mr_sg() driver implementation,
>   rather than post_send's IB_WR_REG_MR
> * misc.: placed code in proper patch, fixed a few comments,
>   removed extra parentheses
>
> Thanks for everyone which pointed out problems in the driver.
>
> Any review/comment is appreciated.

Very nice,
Any reason why didn't you drop debug module parameter and decided to
mimic already available kernel core functionality?

You got technical explanations why it is bad idea to use it. If you need additional voices
to support my claims, you will find them in thread about VERBOSE flag and responses from
Doug, and Dennis.

Thanks

--SCOJXUq1iwCn05li
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX4SeHAAoJEORje4g2clin/5sP/AkNvEkCHcr6RNO3CveSdh1s
iNoen5fvmjBtIJufws58BSeM4txW50YcXggdsD9dgVDR9f994qeW2XP2pesqCOvX
SsCpjnsR4z25373rq0I2/iT5evCV+UGIrlxACivyNIOzFvVZSXE1wPKfQu2GuntN
5Pdzf9xZ1LkpwGAj9GaDTs74gJ/kmesbuIONcc3Qtujtnjnw660a3eLeiKb1p1Su
pcfOwityDVfKDdam4dojvQ8ecPTsfWKOIndx5AJjOejF9d6K4xwTEPreMpYVU/KH
sWL6mINjgt2h8k+KUa8XQanYttRYw//zs+r0wgyrLT4cuwwk0QeGukSLzDusBIT1
3eXc3Mz+MSe+S9aBDFA1tn7aS9t6IGgxmzDXJFKC6FLFZbtIaUO1TMj/6iYO7VrK
TlQW4iYov2TlHKrvrlgAdc9MPwRuXd0QS31jLqg/Yf7fCHwUIs84IJJ8XLV//qJZ
fhbDh/MApLRw+ZrK28WYeMQtS/tmACdopjVKM3F1Zodrz6pJtqTm2Q8eXFjW8pxG
UEd/SD7+iCaBwcM0brRYLUHS04tm4E6s7n43gor+DrzXF2Nwte1Gb/jSmZpMEkE4
0i87vk3ZwTSFBmU1kXr4/1Q4grmnNbhsOu/UGKLhx1Y+O3MPp780hFR7lsq51rZN
9LhJVq/+gMsjgKXizWSM
=bDJt
-----END PGP SIGNATURE-----

--SCOJXUq1iwCn05li--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
