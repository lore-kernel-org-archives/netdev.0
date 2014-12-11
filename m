From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH net-next 1/3] net: fec: reset fep link status in suspend
 function
Date: Thu, 11 Dec 2014 01:40:16 +0000
Message-ID: <BLUPR03MB37304C36DEF8BB3A09F2E14F5630@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1418205289-7730-1-git-send-email-b38611@freescale.com>
	<1418205289-7730-2-git-send-email-b38611@freescale.com>
 <20141210.145424.35618035568083747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0117.outbound.protection.outlook.com ([65.55.169.117]:37664
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932937AbaLKBkT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 20:40:19 -0500
In-Reply-To: <20141210.145424.35618035568083747.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net> Sent: Thursday, December 11, 2014 3:54 AM
> To: Duan Fugang-B38611
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> stephen@networkplumber.org
> Subject: Re: [PATCH net-next 1/3] net: fec: reset fep link status in
> suspend function
> 
> From: Fugang Duan <b38611@freescale.com>
> Date: Wed, 10 Dec 2014 17:54:47 +0800
> 
> > +	/*
> > +	 * SOC supply clock to phy, when clock is disabled, phy link down
> > +	 * SOC control phy regulator, when regulator is disabled, phy link
> down
> > +	 */
> 
> Comments in the networking should be of the form:
> 
> 	/* Like
> 	 * this.
> 	 */
> 
> Not:
> 
> 	/*
> 	 * Like
> 	 * this.
> 	 */

Thanks for your comment. I will change it and send V2 version.

Regards,
Andy
