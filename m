From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v5 08/10] ARM: mxs: add ocotp read function
Date: Fri, 14 Jan 2011 10:48:32 +0100
Message-ID: <20110114094832.GG24920@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294989894-20780-1-git-send-email-shawn.guo@freescale.com>
 <20110114084009.GL26617@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, gerg@snapgear.com,
	B32542@freescale.com, netdev@vger.kernel.org, jamie@shareable.org,
	baruch@tkos.co.il, w.sang@pengutronix.de, r64343@freescale.com,
	eric@eukrea.com, bryan.wu@canonical.com, jamie@jamieiles.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	lw@karo-electronics.de
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54481 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab1ANJtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 04:49:03 -0500
Content-Disposition: inline
In-Reply-To: <20110114084009.GL26617@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sascha,

On Fri, Jan 14, 2011 at 09:40:09AM +0100, Sascha Hauer wrote:
> On Fri, Jan 14, 2011 at 03:24:54PM +0800, Shawn Guo wrote:
> > +const u32 *mxs_get_ocotp(void)
> > +{
> > + [...]
> > +}
>=20
> EXPORT_SYMBOL?
I don't think this should be necessary.  mxs_get_ocotp should only be
called from platform code that cannot (ot at least should not) be
modular.  I suggest to skip it for now and if we really need it later
only add it then.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
