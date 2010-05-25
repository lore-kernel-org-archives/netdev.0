From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [stable-2.6.32 PATCH] ixgbe: backport bug fix for tx panic
Date: Tue, 25 May 2010 00:15:12 -0700
Message-ID: <AANLkTinHm8ukQ3KlcrMKWvQ-QrlmBcWeVD-i99Q9Z7JL@mail.gmail.com>
References: <20100511004655.30590.74584.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Brandon <brandon@ifup.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: stable@kernel.org, greg@kroah.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100511004655.30590.74584.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 10, 2010 at 17:46, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
> backporting this commit:
>
> commit fdd3d631cddad20ad9d3e1eb7dbf26825a8a121f
> Author: Krishna Kumar <krkumar2@in.ibm.com>
> Date: =C2=A0 Wed Feb 3 13:13:10 2010 +0000
>
> =C2=A0 =C2=A0ixgbe: Fix return of invalid txq
>
> =C2=A0 =C2=A0a developer had complained of getting lots of warnings:
>
> =C2=A0 =C2=A0"eth16 selects TX queue 98, but real number of TX queues=
 is 64"
>
> =C2=A0 =C2=A0http://www.mail-archive.com/e1000-devel@lists.sourceforg=
e.net/msg02200.html
>
> =C2=A0 =C2=A0As there was no follow up on that bug, I am submitting t=
his
> =C2=A0 =C2=A0patch assuming that the other return points will not ret=
urn
> =C2=A0 =C2=A0invalid txq's, and also that this fixes the bug (not tes=
ted).
>
> =C2=A0 =C2=A0Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> =C2=A0 =C2=A0Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.=
com>
> =C2=A0 =C2=A0Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@i=
ntel.com>
> =C2=A0 =C2=A0Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com=
>
> =C2=A0 =C2=A0Signed-off-by: David S. Miller <davem@davemloft.net>
>
> CC: Brandon <brandon@ifup.org>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> ---
>
> =C2=A0drivers/net/ixgbe/ixgbe_main.c | =C2=A0 =C2=A08 ++++++--
> =C2=A01 files changed, 6 insertions(+), 2 deletions(-)
>

Greg - status?  Did you queue this patch for the stable release and I m=
issed it?

--=20
Cheers,
Jeff
