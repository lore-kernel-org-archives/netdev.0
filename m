From: Peter Chen <peter.chen@freescale.com>
Subject: Re: [PATCH 1/1] Revert "net: fec: Ensure clocks are enabled while
 using mdio bus"
Date: Fri, 14 Aug 2015 16:14:45 +0800
Message-ID: <20150814081444.GD11072@shlinux2>
References: <1439531254-13128-1-git-send-email-peter.chen@freescale.com>
 <1439540577.13210.25.camel@pengutronix.de>
 <BN3PR0301MB08490760B426D4889AFF2434817C0@BN3PR0301MB0849.namprd03.prod.outlook.com>
 <1439540853.13210.26.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Duan Andy <fugang.duan@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	"tyler.baker@linaro.org" <tyler.baker@linaro.org>,
	Andrew Lunn <andrew@lunn.ch>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0134.outbound.protection.outlook.com ([207.46.100.134]:6869
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754001AbbHNJZk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 05:25:40 -0400
Content-Disposition: inline
In-Reply-To: <1439540853.13210.26.camel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2015 at 10:27:33AM +0200, Lucas Stach wrote:
> Am Freitag, den 14.08.2015, 08:25 +0000 schrieb Peter Chen:
> >  
> > > 
> > > Am Freitag, den 14.08.2015, 13:47 +0800 schrieb Peter Chen:
> > > > It causes the i.mx6sx sdb board hang when using nfsroot during boots
> > > > up at v4.2-rc6.
> > > >
> > > > This reverts commit 8fff755e9f8d0f70a595e79f248695ce6aef5cc3.
> > > >
> > > > Cc: netdev@vger.kernel.org
> > > > Cc: Fugang Duan <B38611@freescale.com>
> > > > Cc: shawn.guo@linaro.org
> > > > Cc: fabio.estevam@freescale.com
> > > > Cc: tyler.baker@linaro.org
> > > > Cc: Lucas Stach <l.stach@pengutronix.de>
> > > > Cc: Andrew Lunn <andrew@lunn.ch>
> > > > Signed-off-by: Peter Chen <peter.chen@freescale.com>
> > > > ---
> > > >
> > > > According to Fugang Duan, the i.mx series has different clock control
> > > > sequence among SoCs, this patch may only consider certain SoCs.
> > > >
> > > Sorry, but NACK.
> > > 
> > > Please test current mainline (what will become v4.2-rc7). There is already a
> > > patch in that fixes i.MX27 and probably fixes the same problem on i.MX6SX.
> > > 
> > 
> > Would you help point to me which commit and at which tree?
> > 
> Mainline, so Linus Torvalds tree.
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=14d2b7c1a96ef37eb571599c73d4a1a606b964d6

It fixes my imx6sx-sdb board. It is interesting that there was
no problem for some platforms, but with problem for others.
Your fix is a common runtime PM fix.

Again, why we need this as a bug-fix, not but as new feature for next
rc1?

-- 

Best Regards,
Peter Chen
