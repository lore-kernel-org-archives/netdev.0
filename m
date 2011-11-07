From: Zhao Chenhui <chenhui.zhao@freescale.com>
Subject: Re: [PATCH 6/7] fsl_pmc: Add API to enable device as wakeup event
 source
Date: Mon, 7 Nov 2011 19:24:11 +0800
Message-ID: <20111107112411.GC16470@localhost.localdomain>
References: <1320410349-14600-1-git-send-email-chenhui.zhao@freescale.com>
 <CAOZdJXXB9zJWqC+kPq7ZDdzePtp8XNBnWcf5UmE8Ye50U-G7Dg@mail.gmail.com>
Reply-To: <zch@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zhao Chenhui-B35336 <B35336@freescale.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	Li Yang-R58472 <r58472@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tabi Timur-B04825 <B04825@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-cpk.frontbridge.com ([204.231.192.41]:27435 "EHLO
	WA2EHSNDR005.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753534Ab1KGLYM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 06:24:12 -0500
Content-Disposition: inline
In-Reply-To: <CAOZdJXXB9zJWqC+kPq7ZDdzePtp8XNBnWcf5UmE8Ye50U-G7Dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2011 at 07:08:24PM -0500, Tabi Timur-B04825 wrote:
> On Fri, Nov 4, 2011 at 7:39 AM, Zhao Chenhui <chenhui.zhao@freescale.=
com> wrote:
>=20
> > + =A0 =A0 =A0 if (!pmc_regs) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING "PMC is unavailab=
le\n");
>=20
> Use pr_warn() and the other pr_xxx functions.
>=20
> > + =A0 =A0 =A0 pmcdr_mask =3D (u32 *)of_get_property(clk_np, "fsl,pm=
cdr-mask", NULL);
>=20
> The typecast is unnecessary here.
>=20
> > + =A0 =A0 =A0 /* clear to enable clock in low power mode */
> > + =A0 =A0 =A0 if (enable)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clrbits32(&pmc_regs->pmcdr, *pmcdr_ma=
sk);
> > + =A0 =A0 =A0 else
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 setbits32(&pmc_regs->pmcdr, *pmcdr_ma=
sk);
>=20
> You need to use be32_to_cpup() when dereferencing a pointer to a
> device tree property.
>=20
> --=20
> Timur Tabi
> Linux kernel developer at Freescale

Thanks. I will fix them all.

-chenhui
