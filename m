From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] Revert "net/macb: add pinctrl consumer support"
Date: Fri, 26 Sep 2014 13:06:20 -0700
Message-ID: <b3c8ab73-4dd5-436e-9647-c4a43e40c3a9@BL2FFO11FD051.protection.gbl>
References: <1411429748-31444-1-git-send-email-soren.brinkmann@xilinx.com>
 <20140926.154930.1459165439870528648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <nicolas.ferre@atmel.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140926.154930.1459165439870528648.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-09-26 at 03:49PM -0400, David Miller wrote:
> From: Soren Brinkmann <soren.brinkmann@xilinx.com>
> Date: Mon, 22 Sep 2014 16:49:08 -0700
>=20
> > This reverts commit 8ef29f8aae524bd51298fb10ac6a5ce6c4c5a3d8.
> > The driver core already calls pinctrl_get() and claims the default
> > state. There is no need to replicate this in the driver.
> > ---
> > Hi,
> >=20
> > I might be mistaken, but I think the driver core does already take =
care of
> > calling into the pinctrl framework and the driver does not need to =
do it on its
> > own (drivers/base/dd.c:really_probe() calls 'pinctrl_bind_pins() wh=
ich takes
> > care of the pinctrl setup).
> >=20
>=20
> Applied and queued up for -stable, thanks.

thx

> Next time please provide a proper "Signed-off-by: " in the commit mes=
sage
> of your submission.

Yeah, sorry for that. I overlooked that one. My alias for commit takes
care of this, but I don't have that for revert.

In case you need it:
Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>

	S=C3=B6ren
