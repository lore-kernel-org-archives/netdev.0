From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] tg3: Allow GPHY powerdown on 5761
Date: Fri, 21 Nov 2008 17:21:21 -0800 (PST)
Message-ID: <20081121.172121.164339031.davem@davemloft.net>
References: <1227295576.5624@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755808AbYKVBVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:21:22 -0500
In-Reply-To: <1227295576.5624@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 21 Nov 2008 11:02:15 -0800

> The ENABLE_APE flag tells the driver whether or not the device has an
> Application Processing Engine (APE).  The APE does not need the PHY to
> be powered unless it is running management firmware.  For backwards
> compatibility, management firmware will still set the ENABLE_ASF bit.
> Consequently, there is no reason to consider the ENABLE_APE flag when
> deciding whether or not to power down the phy.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
