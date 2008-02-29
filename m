From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/08 net-2.6.26] [TIPC]: Add argument validation for
 shutdown()
Date: Fri, 29 Feb 2008 11:47:41 -0800 (PST)
Message-ID: <20080229.114741.65905086.davem@davemloft.net>
References: <AF1602CB2550CE4381C0C75118A7856B0252DE21@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39425
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758482AbYB2Trm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:47:42 -0500
In-Reply-To: <AF1602CB2550CE4381C0C75118A7856B0252DE21@ala-mail02.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Stephens, Allan" <allan.stephens@windriver.com>
Date: Fri, 29 Feb 2008 10:40:44 -0800

> +#ifndef SHUT_RDWR
> +#define SHUT_RDWR 2
> +#endif
> +

Please don't handle things this way, it's extremely ugly.
