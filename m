From: Artem Bityutskiy <dedekind1@gmail.com>
Subject: Re: [RFC] Online firmware upgrade in non-embedded systems
Date: Wed, 29 Sep 2010 15:34:18 +0300
Message-ID: <1285763658.2437.112.camel@localhost>
References: <1285696787.2282.45.camel@achroite.uk.solarflarecom.com>
Reply-To: dedekind1@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-mtd <linux-mtd@lists.infradead.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285696787.2282.45.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-09-28 at 18:59 +0100, Ben Hutchings wrote:
> Currently the sfc network driver is optionally combined with an MTD
> driver (CONFIG_SFC_MTD) which exposes all upgradable firmware and
> configuration partitions in flash.  This works nicely in kernels with
> MTD enabled, but since MTD is mainly used in embedded systems with
> on-board flash it is often disabled in distribution kernels and custo=
m
> kernels alike.  This leaves users of sfc unable to upgrade firmware
> without rebuilding the kernel or booting some other distribution.  Th=
e
> lack of widespread MTD support is a regular cause of support requests=
=2E

At least Fedora does have MTD enabled. But I guess commercial
distributions like RHEL might have it disabled (but I did not check),
and I think I could guess the reason for this.

--=20
Best Regards,
Artem Bityutskiy (=D0=90=D1=80=D1=82=D1=91=D0=BC =D0=91=D0=B8=D1=82=D1=8E=
=D1=86=D0=BA=D0=B8=D0=B9)
