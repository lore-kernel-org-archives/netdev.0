From: Duan Andy <fugang.duan@freescale.com>
Subject: RE: [PATCH v1 0/6] Add fec1 and fec2 support for i.MX7d sdb board
Date: Fri, 21 Aug 2015 23:49:41 +0000
Message-ID: <BN3PR0301MB1219615039D291CCCD751B2EF5650@BN3PR0301MB1219.namprd03.prod.outlook.com>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com>
 <20150820.140531.1320709021949935376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawnguo@kernel.org" <shawnguo@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0106.outbound.protection.outlook.com ([65.55.169.106]:44702
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750970AbbHUXtn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 19:49:43 -0400
In-Reply-To: <20150820.140531.1320709021949935376.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net> Sent: Friday, August 21, 2015 5:06 AM
> To: Duan Fugang-B38611
> Cc: shawnguo@kernel.org; linux-arm-kernel@lists.infradead.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH v1 0/6] Add fec1 and fec2 support for i.MX7d sdb
> board
> 
> From: Fugang Duan <b38611@freescale.com>
> Date: Wed, 19 Aug 2015 13:33:58 +0800
> 
> > The patch series is to add fec support for i.MX7d sdb board. Since
> > i.MX7d fec ip is the same as i.MX6SX, so there have no change for
> driver itself.
> >
> > Patch#1: add bcm54220 PHY ID entry into brcmphy.h file.
> 
> This is completely, and utterly, pointless.
> 
> The only reason a PHY ID should be defined in brcmphy.h is so that it can
> be used in the broadcom.c PHY driver or similar.
> 
> If there is no user in the tree, there is no reason to add it to the
> header file.

Ok, I will try to add the phy support in Broadcom phy driver. Thanks for your comment.

Regards,
Andy
