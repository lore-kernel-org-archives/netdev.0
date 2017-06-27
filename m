From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: RE: [RFC 02/19] qed: Implement iWARP initialization, teardown and qp
 operations
Date: Tue, 27 Jun 2017 08:33:34 +0000
Message-ID: <DM2PR0701MB13925426BCEFE46D7935C53F88DC0@DM2PR0701MB1392.namprd07.prod.outlook.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
 <1498500429-22557-3-git-send-email-Michal.Kalderon@cavium.com>
 <20170627054541.GN1248@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0079.outbound.protection.outlook.com ([104.47.38.79]:13926
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751513AbdF0Idg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 04:33:36 -0400
In-Reply-To: <20170627054541.GN1248@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky [mailto:leon@kernel.org]
Sent: Tuesday, June 27, 2017 8:46 AM
>=20
> On Mon, Jun 26, 2017 at 09:06:52PM +0300, Michal Kalderon wrote:
> > This patch adds iWARP support for flows that have common code between
> > RoCE and iWARP, such as initialization, teardown and qp setup verbs:
> > create, destroy, modify, query.
> > It introduces the iWARP specific files qed_iwarp.[ch] and
> > iwarp_common.h
> >
> > Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
> > Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
> > Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
> >
> > ---
>=20
> <...>
>=20
> > +#define QED_IWARP_PARAM_P2P		(1)
>=20
> <...>
>=20
> > +
> > +	iwarp_info->peer2peer =3D QED_IWARP_PARAM_P2P;
>=20
> Can you shed a light what is it?
> Thanks
It's a mode in MPA rev2,  It's currently hard coded, and we plan on making =
this configurable in the future, we're looking into using the rdmatool,
