From: Peter Dawson <petedaws@gmail.com>
Subject: Re: [PATCH] ip6_tunnel: Correct tos value in collect_md mode
Date: Wed, 14 Jun 2017 15:28:39 +1000
Message-ID: <20170614152839.38406ce2@gmail.com>
References: <1497408497-1473-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
        <9E61EADF-769B-431A-81EA-ADBAAD32ABD3@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: =?UTF-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9E61EADF-769B-431A-81EA-ADBAAD32ABD3@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2017 10:54:31 +0800
=E4=B8=A5=E6=B5=B7=E5=8F=8C <yanhaishuang@cmss.chinamobile.com> wrote:


> > Changes since v2:
> >  * mask key->tos with RT_TOS() suggested by Daniel

Can you help me understand the rationale for this change? Is there are bug =
introduced by dsfield =3D ip6_tclass(key->label); ?

The RT_TOS masks out 4bits of the 8bit tos field in accordance with RFC1349=
 (obsoleted by RFC2474). IPv6 does not have a TOS field. So it dosen't make=
 sense to apply a TOS value to the outer header of an IPv6 tunnel.
