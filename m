From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 invalid argument mpls labels
Date: Tue, 15 Aug 2017 08:06:14 -0700
Message-ID: <20170815080614.1a6e79ad@xeon-e3>
References: <77691502785047@web24j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:38705 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751949AbdHOPGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:06:23 -0400
Received: by mail-pg0-f44.google.com with SMTP id l64so7155623pge.5
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 08:06:23 -0700 (PDT)
In-Reply-To: <77691502785047@web24j.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Aug 2017 11:17:27 +0300
=D0=90=D0=BB=D0=B5=D0=BA=D1=81=D0=B5=D0=B9 =D0=91=D0=BE=D0=BB=D0=B4=D1=8B=
=D1=80=D0=B5=D0=B2         <devel-net-ne-vlezay80@yandex.ru> wrote:

> I updated the kernel 4.12.6. When the mote is hung on the route more than=
 8 mpls of marks through iproute2, I get the following:
>=20
> root@ne-vlezay80:~# ip route add 10.10.10.0/24 encap mpls 50/60/70/80/90/=
100/110/120/130 dev lo
> RTNETLINK answers: Invalid argument
>=20
> root@ne-vlezay80:~# ip route add 10.10.10.0/24 encap mpls 50/60/70/80/90/=
100/110/120 dev lo
> root@ne-vlezay80:~#
>=20
> root@ne-vlezay80:~# ip r
> default via 10.247.0.1 dev ic-br0 proto zebra metric 20=20
> 10.10.10.0/24  encap mpls  ///////120 dev lo scope link=20
>=20
> root@ne-vlezay80:~# cat /usr/src/linux-4.12.6/net/mpls/internal.h|grep MA=
X_NEW
> #define MAX_NEW_LABELS 30
> root@ne-vlezay80:~#=20
>=20
> What is the problem, and how can more than 8 MPLS markers be hung on thro=
ugh iproute2?
>=20
> root@ne-vlezay80:~# uname -r
> 4.12.6
> root@ne-vlezay80:~#=20

iproute2 just reports what the kernel response is. The invalid argument err=
or=20
comes from the kernel.
