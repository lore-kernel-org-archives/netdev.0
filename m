From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 11/19] sis900 warning fixes
Date: Tue, 06 Mar 2007 06:15:47 -0500
Message-ID: <45ED4D63.5030901@garzik.org>
References: <200703061041.l26AftIO019765@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53277 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964962AbXCFLPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:15:48 -0500
In-Reply-To: <200703061041.l26AftIO019765@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> diff -puN drivers/net/sis900.c~sis900-warning-fixes drivers/net/sis900.c
> --- a/drivers/net/sis900.c~sis900-warning-fixes
> +++ a/drivers/net/sis900.c
> @@ -1430,7 +1430,7 @@ static void sis900_auto_negotiate(struct
>  	int i = 0;
>  	u32 status;
>  
> -	while (i++ < 2)
> +	for (i = 0; i < 2; i++)
>  		status = mdio_read(net_dev, phy_addr, MII_STATUS);
>  
>  	if (!(status & MII_STAT_LINK)){

applied, though, you missed killing a redundant initialization


