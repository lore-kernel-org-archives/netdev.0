From: roel kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] obsolete config in kernel source (USE_INTERNAL_TIMER)
Date: Fri, 5 Feb 2010 15:16:25 +0100
Message-ID: <25e057c01002050616x59c927fbpaf13f477ec012ec5@mail.gmail.com>
References: <20100205132219.GA6874@faui49.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vamos@i4.informatik.uni-erlangen.de
To: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100205132219.GA6874@faui49.informatik.uni-erlangen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> =C2=A0 =C2=A0 =C2=A0 =C2=A0As part of the VAMOS[0] research project a=
t the University of
> Erlangen we're checking referential integrity between kernel KConfig
> options and in-code Conditional blocks.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0USE_INTERNAL_TIMER is another candidate. A=
s can be seen on the
> comment of the #undef instruction this part was quite likely never
> working and safeguards were added si it is never enabled.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Please keep me informed of this patch gett=
ing confirmed /
> merged so we can keep track of it.
>
> Regards
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Christoph Egger
>
> [0] http://vamos1.informatik.uni-erlangen.de/
>
> ----
> From f027b61661aaac1fd58536e17894e486d5fb3d3f Mon Sep 17 00:00:00 200=
1
> From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
> Date: Fri, 5 Feb 2010 13:11:16 +0100
> Subject: [PATCH] USE_INTERNAL_TIMER explicitely #undef-ed and not in =
kconfig
>
> CONFIG_USE_INTERNAL_TIMER seems to be the remainings of some
> experiment. It is explicitely #undef-ed as not working, only
> referenced from one source file and rather aged.
>
> Hereby cleaning it from the kernel tree.
>
> Signed-off-by: Christoph Egger <siccegge@stud.informatik.uni-erlangen=
=2Ede>

Looks correct to me,

Acked-by: Roel Kluin <roel.kluin@gmail.com>
