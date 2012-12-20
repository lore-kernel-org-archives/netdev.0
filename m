From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 4/4] net/smsc911x: Provide common clock functionality
Date: Thu, 20 Dec 2012 20:35:14 +0000
Message-ID: <20121220203514.GN2691@gmail.com>
References: <1355937587-31730-1-git-send-email-lee.jones@linaro.org>
 <1355937587-31730-4-git-send-email-lee.jones@linaro.org>
 <CACRpkda79O_b3Z8g7Sy7vMtW9neZU4x-Z=iEQgjqu4X5tFKyhw@mail.gmail.com>
 <20121220192441.GC14363@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@linaro.org>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Robert Marklund <robert.marklund@stericsson.com>,
	linus.walleij@stericsson.com, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:32895 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666Ab2LTUfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 15:35:19 -0500
Received: by mail-we0-f170.google.com with SMTP id r1so1884460wey.1
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 12:35:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121220192441.GC14363@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2012, Russell King - ARM Linux wrote:

> On Thu, Dec 20, 2012 at 08:12:08PM +0100, Linus Walleij wrote:
> > On Wed, Dec 19, 2012 at 6:19 PM, Lee Jones <lee.jones@linaro.org> w=
rote:
> >=20
> > > Some platforms provide clocks which require enabling before the
> > > SMSC911x chip will power on. This patch uses the new common clk
> > > framework to do just that. If no clock is provided, it will just
> > > be ignored and the driver will continue to assume that no clock
> > > is required for the chip to run successfully.
> > >
> > > Cc: Steve Glendinning <steve.glendinning@shawell.net>
> > > Cc: netdev@vger.kernel.org
> > > Signed-off-by: Lee Jones <lee.jones@linaro.org>
> >=20
> > Seems to me like it'll do the trick.
> > Acked-by: Linus Walleij <linus.walleij@linaro.org>
>=20
> This looks fairly dangerous.  What about those platforms which use th=
is
> driver, but don't provide a clock for it?
>=20
> It looks like this will result in those platforms losing their ethern=
et
> support.  There's at least a bunch of the ARM evaluation boards which
> make use of this driver...

Right, but nothing should regress. If no clock is provided the driver
moves on during the request and will refuse to prepare, enable and
disable there after.=20

Unless I've made a mistake somewhere? If so, I'd be happy to fixup.

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
