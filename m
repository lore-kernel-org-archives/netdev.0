From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net-next 1/1] net: tcp: Define the TCP_MAX_WSCALE instead of literal number 14
Date: Mon, 3 Apr 2017 21:26:10 +0800
Message-ID: <002901d2ac7d$dcb7fae0$9627f0a0$@foxmail.com>
References: <1491020050-118525-1-git-send-email-gfree.wind@foxmail.com> <CADVnQy=WSQb0bz-gRFfNK8uTyJ-ALdUPhR05iThZ8fs=K=qm2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: "'David Miller'" <davem@davemloft.net>,
        "'Alexey Kuznetsov'" <kuznet@ms2.inr.ac.ru>,
        "'James Morris'" <jmorris@namei.org>,
        "'Patrick McHardy'" <kaber@trash.net>,
        "'Netdev'" <netdev@vger.kernel.org>, "'Gao Feng'" <fgao@ikuai8.com>
To: "'Neal Cardwell'" <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgbr2.qq.com ([54.207.22.56]:51093 "EHLO smtpbgbr2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752463AbdDCN0o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 09:26:44 -0400
In-Reply-To: <CADVnQy=WSQb0bz-gRFfNK8uTyJ-ALdUPhR05iThZ8fs=K=qm2w@mail.gmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Neal Cardwell [mailto:ncardwell@google.com]
> Sent: Monday, April 3, 2017 2:59 AM
> To: gfree.wind@foxmail.com
> Cc: David Miller <davem@davemloft.net>; Alexey Kuznetsov
> <kuznet@ms2.inr.ac.ru>; James Morris <jmorris@namei.org>; Patrick =
McHardy
> <kaber@trash.net>; Netdev <netdev@vger.kernel.org>; Gao Feng
> <fgao@ikuai8.com>
> Subject: Re: [PATCH net-next 1/1] net: tcp: Define the TCP_MAX_WSCALE
> instead of literal number 14
>=20
> On Sat, Apr 1, 2017 at 12:14 AM,  <gfree.wind@foxmail.com> wrote:
> > From: Gao Feng <fgao@ikuai8.com>
> >
> > Define one new macro TCP_MAX_WSCALE instead of literal number '14',
> > and use U16_MAX instead of 65535 as the max value of TCP window.
> > There is another minor change, use rounddown(space, mss) instead of
> > (space / mss) * mss;
> >
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> > ---
>=20
> Looks OK to me.
>=20
> IMHO this is a nice direction, since there is a proposal to increase =
the maximum
> shift factor from 14 to 15:
>   https://tools.ietf.org/html/draft-nishida-tcpm-maxwin-03

Do you mean enlarge the wscale to 15 now ?

>=20
> Though there are a few spots where a literal 14 appears:
>=20
> tcp_input.c:3763:  net_info_ratelimited("%s: Illegal window scaling
> value %d >14 received\n",
>=20
> tcp_output.c:238:                * See RFC1323 for an explanation of
> the limit to 14

Ok, I will update these two spots.

Regards
Feng
>=20
>=20
> neal
