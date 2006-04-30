From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/6] tg3: Reset chip when changing MAC address
Date: Sat, 29 Apr 2006 18:58:28 -0700 (PDT)
Message-ID: <20060429.185828.63432613.davem@davemloft.net>
References: <1146267335.4780.16.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18117
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750867AbWD3B6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 21:58:12 -0400
To: mchan@broadcom.com
In-Reply-To: <1146267335.4780.16.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 Apr 2006 16:35:35 -0700

> Do the full chip reset when changing MAC address if ASF is enabled.
> 
> ASF sometimes uses a different MAC address than the driver. Without
> the reset, the ASF MAC address may be overwritten when the driver's
> MAC address is changed.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

A little heavy handed, but I can't think of another way to
deal with this.

Applied, thanks a lot.
