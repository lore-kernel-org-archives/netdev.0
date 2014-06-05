From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 0/6] net: fec: Enable Software TSO to improve the tx
 performance
Date: Thu, 5 Jun 2014 08:11:42 +0000
Message-ID: <1699266c40be4b1cb5aa212390c97dbe@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1401867571-11684-1-git-send-email-b38611@freescale.com>
 <20140604.152850.1591854206282161278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"David.Laight@ACULAB.COM" <David.Laight@ACULAB.COM>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0212.outbound.protection.outlook.com ([207.46.163.212]:11519
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750715AbaFEIL6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 04:11:58 -0400
In-Reply-To: <20140604.152850.1591854206282161278.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David,

From: David Miller <davem@davemloft.net> Data: Thursday, June 05, 2014 6:29 AM
> To: Duan Fugang-B38611
> Cc: netdev@vger.kernel.org; shawn.guo@linaro.org; Estevam Fabio-R49496;
> ezequiel.garcia@free-electrons.com; bhutchings@solarflare.com;
> stephen@networkplumber.org; Li Frank-B20596; David.Laight@ACULAB.COM;
> eric.dumazet@gmail.com
> Subject: Re: [PATCH v2 0/6] net: fec: Enable Software TSO to improve the tx
> performance
> 
> 
> I think you need to start taking David Laight's feedback more seriously.
> 
> He's right, it makes no sense at all the increase the number of RX
> descriptors for the sake of a send side feature like TSO.
> 
> If you have a another reason to increase the RX descriptor count, do it as
> a separate change and with an appropriate commit log message explaining WHY
> you are doing this.
> 
> I'm not applying this patch series until you start taking the feedback you
> are receiving to heart.

Considering with David Laight's suggestion by previous mail, I decide to remove the RX descriptors number change for the patch set.
After the patch set, I have another patch serial for new feature support like interrupt coalescing that request
RX descriptors number is enough big.  I will generate one separate patch to increase RX BDs entry.

I will send the V3 for the change.

Thanks,
Andy
