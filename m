From: Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: Re: [PATCH] dp83640: Get gpio and master/slave configuration from DT
Date: Tue, 11 Feb 2014 09:01:25 +0100
Message-ID: <1392105685.2133.2.camel@e37108.spectralink.com>
References: <1392037240-30913-1-git-send-email-stefan.sorensen@spectralink.com>
	 <20140210184604.GA4296@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <grant.likely@linaro.org>, <robh+dt@kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0210.outbound.protection.outlook.com ([207.46.163.210]:17640
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750776AbaBKIB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Feb 2014 03:01:58 -0500
In-Reply-To: <20140210184604.GA4296@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 19:46 +0100, Richard Cochran wrote:
> On Mon, Feb 10, 2014 at 02:00:40PM +0100, Stefan S=C3=B8rensen wrote:
> > This patch removes the module parameters gpio_tab and chosen_phy in=
 favour of
> > retrieving the configuration from DT through the properties
>=20
> Can we please keep the module parameters? I have two platforms with
> phyters neither of which will ever support DT, namely ixp and m68k,
> and I want to run recent kernels on them.

I will keep the module parameters as fallback. Will it be OK to split
the gpio_tab parameter into separate calibrate-pin, perout-pins and
extts-pins parameters?

> > The configuration is now stored for each master clock device, allow=
ing different=20
> > gpio setups for each master.
>=20
> What do you mean by "each master"? Do you mean each individual PHY de=
vice
> or each group of PHYs on the same MDIO bus?

I mean each group of PHYs. I will reword that.

Stefan
