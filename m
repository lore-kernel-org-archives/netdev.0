From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Call netif_carrier_off at the end of the
 probe
Date: Thu, 17 Feb 2011 14:10:11 -0800 (PST)
Message-ID: <20110217.141011.59671324.davem@davemloft.net>
References: <1297771719-14202-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, aabdulla@nvidia.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45838
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751550Ab1BQWJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:09:35 -0500
In-Reply-To: <1297771719-14202-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Tue, 15 Feb 2011 13:08:39 +0100

> Without calling of netif_carrier_off at the end of the probe the operstate
> is unknown when the device is initially opened. By default the carrier is
> on so when the device is opened and netif_carrier_on is called the link
> watch event is not fired and operstate remains zero (unknown).
> 
> This patch fixes this behavior in forcedeth and r8169.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks Ivan.
