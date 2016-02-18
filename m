From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] rose: correct integer overflow check
Date: Fri, 19 Feb 2016 00:21:36 +0100
Message-ID: <20160218232136.GB11796@linux-mips.org>
References: <1455740713-18262-1-git-send-email-wuninsu@gmail.com>
 <20160218.153329.28621505199573578.davem@davemloft.net>
 <CAGoFzNd3egg-36bg3DRU=2b5weyuf-CLTcgfWUQmY7kjdBwuNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-hams@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Taesoo Kim <taesoo@gatech.edu>,
	Yeongjin Jang <yeongjin.jang@gatech.edu>,
	"Yun, Insu" <insu@gatech.edu>, Changwoo Min <changwoo@gatech.edu>
To: Insu Yun <wuninsu@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGoFzNd3egg-36bg3DRU=2b5weyuf-CLTcgfWUQmY7kjdBwuNg@mail.gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 18, 2016 at 04:03:16PM -0500, Insu Yun wrote:

>=20
>     Because of the types on the right hand side of the comparison
>     the expressions are all promoted to unsigned.
>=20
>     Did you look at the compiler's assembler output?=A0 I did when
>     reviewing your patch.
>=20
>=20
> I checked the assembler output right now.
> You are right.
> I realized that right hand side becomes unsigned due to sizeof.
> I think this patch is wrong.=A0
> Thanks.=A0

On a different level, the current whole approach of ROSE to just genera=
te
a fixed number of devices at initialization time of ROSE is if not wron=
g
then at least very archaic.  The default number is 10 devices and proba=
bly
of those 9 are unused on a typical setup - that is, if the module has
been loaded intentionally at all.

As a solution I've implemented a patch to support creating of ROSE
devices through netlink plus the necessary changes to iproute2 to go
along with that.

  Ralf
--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
