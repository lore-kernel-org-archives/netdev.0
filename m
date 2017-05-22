From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2] Add missing <sys/types.h> include
Date: Mon, 22 May 2017 13:23:33 -0700
Message-ID: <20170522132333.4240e32b@xeon-e3>
References: <8afdd8babb9e82bcfde78e851b24b698436a6f9f.1495459674.git.baruch@tkos.co.il>
        <5cdba9c8dc972d25219517ade6129faf73f459b3.1495459674.git.baruch@tkos.co.il>
        <20170522102442.51d36c39@xeon-e3>
        <20170522200923.6kn25ulx5mtrv6gi@tarshish>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33707 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932681AbdEVUXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 16:23:45 -0400
Received: by mail-pf0-f173.google.com with SMTP id e193so92521435pfh.0
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 13:23:45 -0700 (PDT)
In-Reply-To: <20170522200923.6kn25ulx5mtrv6gi@tarshish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 May 2017 23:09:23 +0300
Baruch Siach <baruch@tkos.co.il> wrote:

> Hi Stephen,
>=20
> On Mon, May 22, 2017 at 10:24:42AM -0700, Stephen Hemminger wrote:
> > On Mon, 22 May 2017 16:27:54 +0300
> > Baruch Siach <baruch@tkos.co.il> wrote:
> >  =20
> > > From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> > >=20
> > > The u_intXX_t types are defined in <sys/types.h>, so it should be
> > > included before using those types. Otherwise, with certain C
> > > libraries, the build fails with:
> > >=20
> > > In file included from ../include/iptables.h:4:0,
> > >                  from m_ipt.c:18:
> > > ../include/iptables_common.h:47:16: error: unknown type name =E2=80=
=98u_int32_t=E2=80=99
> > >  #define __le32 u_int32_t
> > >=20
> > > Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> > > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > > ---
> > >  include/iptables_common.h | 2 ++
> > >  1 file changed, 2 insertions(+)
> > >=20
> > > diff --git a/include/iptables_common.h b/include/iptables_common.h
> > > index 9099667ffa6d..2c27a4b61fcd 100644
> > > --- a/include/iptables_common.h
> > > +++ b/include/iptables_common.h
> > > @@ -43,6 +43,8 @@ extern char *lib_dir;
> > >    extern void init_extensions(void);
> > >  #endif
> > > =20
> > > +#include <sys/types.h>
> > > +
> > >  #define __be32	u_int32_t
> > >  #define __le32	u_int32_t
> > >  #define __be16	u_int16_t =20
> >=20
> > This include file comes from netfilter, so not going to change it in ip=
route2 repo. =20
>=20
> It turns out that this headers is unused since commit 5cd1adba79d33644 (U=
pdate=20
> to current iptables headers). So this patch is no longer needed.
>=20
> iptables dropped this file in commit a3732db1280 (Moves all declarations =
in=20
> iptables_common.h to xtables.h).
>=20
> baruch
>=20

Ok removed the file
