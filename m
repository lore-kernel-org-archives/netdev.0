From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/15] tg3: Refine phylib support
Date: Mon, 03 Nov 2008 16:55:04 -0800 (PST)
Message-ID: <20081103.165504.193321560.davem@davemloft.net>
References: <1225751627.6193@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753584AbYKDAz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:55:29 -0500
In-Reply-To: <1225751627.6193@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 3 Nov 2008 02:13:56 -0800

> This patch refines the phylib support in the tg3 driver.  The patch does
> the following things :
> 
> * Rename tg3_mdio_config() to tg3_mdio_config_5785().  The 5785 will be
>   the only device that will use it so the name might as well reflect
>   that.
> * Fix a memory leak if mdiobus_register() fails.
> * Add code to deal with phy device detection failures.
> * Add code to correct the supported list of phy features based on the
>   MAC <=> PHY interface.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
