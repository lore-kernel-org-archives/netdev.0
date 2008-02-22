From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: ethtool phys_id default (rev2)
Date: Fri, 22 Feb 2008 11:16:42 -0800
Message-ID: <1203707802.13495.169.camel@dell>
References: <20080222102429.7e48f1f1@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jgarzik@pobox.com>, netdev <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4262 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757807AbYBVTOI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 14:14:08 -0500
In-Reply-To: <20080222102429.7e48f1f1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-02-22 at 10:24 -0800, Stephen Hemminger wrote:
> When asked to blink LEDs the tg3 driver behaves when using:
> 	ethtool -p ethX
> The default value for data is zero, and other drivers interpret this
> as blink forever (or at least a really long time).  The tg3 driver
> interprets this as blink once.  All drivers should have the same
> behaviour.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Michael Chan <mchan@broadcom.com>

We should do this across the board for bnx2, bnx2x, and niu as well.


