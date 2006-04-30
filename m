From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/6] tg3: Add phy workaround
Date: Sat, 29 Apr 2006 18:57:28 -0700 (PDT)
Message-ID: <20060429.185728.67498626.davem@davemloft.net>
References: <1146267319.4780.15.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60642
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750861AbWD3B5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 21:57:17 -0400
To: mchan@broadcom.com
In-Reply-To: <1146267319.4780.15.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 28 Apr 2006 16:35:19 -0700

> Add some PHY workaround code to reduce jitter on some PHYs.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.

It really bugs me that all of this indirect addressing into
the DSP is done with magic addresses and register values.  It
would be great to get some defined in tg3.h that documented
the DSP register set properly.
