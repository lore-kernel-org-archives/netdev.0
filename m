From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] IrDA: irda-usb, unregister netdev when patch upload
 fails
Date: Fri, 14 Apr 2006 16:02:56 -0700 (PDT)
Message-ID: <20060414.160256.59831236.davem@davemloft.net>
References: <20060414101607.GA32724@irie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, jt@hpl.hp.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46537
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751438AbWDNXER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 19:04:17 -0400
To: samuel.ortiz@nokia.com
In-Reply-To: <20060414101607.GA32724@irie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel.ortiz@nokia.com>
Date: Fri, 14 Apr 2006 13:16:07 +0300

> Hi David,
> 
> In the STIR421x case, when the firmware upload fails, we need to unregister_netdev. Otherwise we hit a BUG on free_netdev(), if sysfs is enabled.
>  
> Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>

Applied, but please become familiar with the carriage return key on
your keyboard and format your changelog descirptions to ~80 columns.

Thanks.

