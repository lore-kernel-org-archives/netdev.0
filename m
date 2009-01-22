From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: Add suspend/resume support to SMSC PHYs
Date: Wed, 21 Jan 2009 16:05:39 -0800 (PST)
Message-ID: <20090121.160539.178546954.davem@davemloft.net>
References: <1232459038-13156-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51068
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754323AbZAVAFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 19:05:37 -0500
In-Reply-To: <1232459038-13156-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 20 Jan 2009 13:43:58 +0000

> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index c05d38d..185dcd9 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
> @@ -81,6 +81,9 @@ static struct phy_driver lan83c185_driver = {
>  	.ack_interrupt	= smsc_phy_ack_interrupt,
>  	.config_intr	= smsc_phy_config_intr,
>  
> +        .suspend	= genphy_suspend,
> +        .resume		= genphy_resume,
> +

Please use tabs, not spaces, here.
