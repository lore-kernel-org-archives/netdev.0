From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: fec: remove memory copy for rx path
Date: Sat, 27 Sep 2014 13:39:37 +0200
Message-ID: <20140927113937.GA25265@electric-eye.fr.zoreil.com>
References: <1411538730-31480-1-git-send-email-b38611@freescale.com>
 <20140926.170720.2230061639326332503.davem@davemloft.net>
 <057807be43ca4c79ad51ab07c668519d@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49531 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbaI0Ljv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 07:39:51 -0400
Content-Disposition: inline
In-Reply-To: <057807be43ca4c79ad51ab07c668519d@BLUPR03MB373.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fugang.duan@freescale.com <fugang.duan@freescale.com> :
> From: David Miller <davem@davemloft.net> Sent: Saturday, September 27, 2014 5:07 AM
[...]
> >We call this rx_copybreak, and there are many drivers you can look at to
> >see how this works.
> >
> >Thanks.
> 
> Great suggestion. I will change it for next version.

Be aware that copybreak module option should be considered legacy.

There is an ethtool api for it.

-- 
Ueimor
