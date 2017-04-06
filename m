From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net 1/1] net: tcp: Don't increase the TCP_MIB_OUTRSTS when fail to transmit RST
Date: Thu, 6 Apr 2017 23:11:23 +0800
Message-ID: <001c01d2aee8$0e807130$2b815390$@foxmail.com>
References: <1491485709-8269-1-git-send-email-gfree.wind@foxmail.com> <CADVnQymp9X3EwmiiocNHU8bQpg7Wb7FvGr4SduKjhLoTv35zMA@mail.gmail.com> <001301d2aede$e1e54f00$a5afed00$@foxmail.com> <CADVnQy=5GXBQzvDtbxQp-0ndJ1KphcxkY42mHsDPST0+sMGw2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: "'David Miller'" <davem@davemloft.net>,
        "'Alexey Kuznetsov'" <kuznet@ms2.inr.ac.ru>,
        "'James Morris'" <jmorris@namei.org>,
        "'Patrick McHardy'" <kaber@trash.net>,
        "'Netdev'" <netdev@vger.kernel.org>
To: "'Neal Cardwell'" <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg65.qq.com ([103.7.28.233]:4660 "EHLO smtpbg65.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751557AbdDFPLa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 11:11:30 -0400
In-Reply-To: <CADVnQy=5GXBQzvDtbxQp-0ndJ1KphcxkY42mHsDPST0+sMGw2A@mail.gmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neal

> -----Original Message-----
>=20
> On Thu, Apr 6, 2017 at 10:05 AM, Gao Feng <gfree.wind@foxmail.com> =
wrote:
> > If so, we should increase the TCP_MIB_OUTRSTS too when fail to alloc =
skb.
> > When machine is overloaded and mem is exhausted, it may fail to =
alloc skb.
>=20
> Moving the increment of TCP_MIB_OUTRSTS to the top of
> tcp_send_active_reset() sounds fine to me.
>=20
> neal
I sent the v2 patch, and didn't change the tcp_v4_send_reset and =
tcp_v6_send_response.
Because I think they are only used during connecting. The rst count is =
not as important as=20
tcp_send_active_reset.

Regards
Feng



.
