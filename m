From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net, vxlan Fix compile warning
Date: Fri, 13 Sep 2013 07:40:10 -0700
Message-ID: <20130913074010.5a778f79@samsung-9>
References: <1379075352-20051-1-git-send-email-prarit@redhat.com>
	<20130913072028.54b1c28d@samsung-9>
	<52331FF7.3070905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jpirko@redhat.com, tgraf@redhat.com,
	"David S. Miller" <davem@davemloft.net>
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:56038 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756704Ab3IMOkP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 10:40:15 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so1335499pdi.27
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 07:40:15 -0700 (PDT)
In-Reply-To: <52331FF7.3070905@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Sep 2013 10:23:51 -0400
Prarit Bhargava <prarit@redhat.com> wrote:

>=20
>=20
> On 09/13/2013 10:20 AM, Stephen Hemminger wrote:
> > On Fri, 13 Sep 2013 08:29:12 -0400
> > Prarit Bhargava <prarit@redhat.com> wrote:
> >=20
> >> Fix a unintialized variable warning.
> >>
> >> drivers/net/vxlan.c: In function =E2=80=98vxlan_sock_add=E2=80=99:
> >> drivers/net/vxlan.c:2240:11: error: =E2=80=98sock=E2=80=99 may be =
used uninitialized in this function [-Werror=3Dmaybe-uninitialized]
> >>   vs->sock =3D sock;
> >>            ^
> >> drivers/net/vxlan.c:2217:17: note: =E2=80=98sock=E2=80=99 was decl=
ared here
> >>   struct socket *sock;
> >>                  ^
> >>
> >> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> >> Cc: jpirko@redhat.com
> >> Cc: tgraf@redhat.com
> >> Cc: "David S. Miller" <davem@davemloft.net>
> >=20
> > Which compiler version? Gcc 4.6 is known to be stupid,
> > and I would rather not change the source if it is only caused
> > by a gcc bug fixed in a later release.
>=20
> Hi Stephen,
>=20
> [root@intel-rosecity-06 ~]# gcc --version
> gcc (GCC) 4.8.1 20130603 (Red Hat 4.8.1-1)
> Copyright (C) 2013 Free Software Foundation, Inc.
> This is free software; see the source for copying conditions.  There =
is NO
> warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PU=
RPOSE.
>=20
> P.

Argh, gcc got stupid again. I guess we have to live it.
Acked-by: Stephen Hemminger <stephen@networkplumber.org>
