From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26 2/2] gianfar: Determine TBIPA value dynamically
Date: Tue, 29 Apr 2008 02:01:12 -0400
Message-ID: <4816B9A8.8080905@pobox.com>
References: <1208278162-17462-1-git-send-email-paul.gortmaker@windriver.com> <1208278162-17462-2-git-send-email-paul.gortmaker@windriver.com> <1208278162-17462-3-git-send-email-paul.gortmaker@windriver.com> <4806A017.4000107@pobox.com> <20080417040809.GA20948@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53436 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757108AbYD2GBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 02:01:16 -0400
In-Reply-To: <20080417040809.GA20948@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Gortmaker wrote:
> In message: Re: [PATCH v2.6.26 2/2] gianfar: Determine TBIPA value dynamically
> on 16/04/2008 Jeff Garzik wrote:
> 
>> ACK, but failed to apply
>>
>> please rediff against jgarzik/netdev-2.6.git#upstream or its parent,  
>> davem/net-2.6.26.git
> 
> Re-diffed against davem/net-2.6.26.git -- this minor change in the context:
> 
> -#define DEFAULT_RXTIME 4
> +#define DEFAULT_RXTIME 21
> 
> overlapped with this patch and caused git to get upset about fuzz.
> Other than this context change, the patch is identical to what you've
> already reviewed.
> 
> Thanks,
> Paul.
> ---
> 
>  From 1f78c8a708b5424fdba33320591258a033f079cd Mon Sep 17 00:00:00 2001
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Tue, 15 Apr 2008 12:23:21 -0400
> Subject: [PATCH] gianfar: Determine TBIPA value dynamically
> 
> TBIPA needs to be set to a value (on connected MDIO buses) that doesn't
> conflict with PHYs on the bus.  By hardcoding it to 0x1f, we were preventing
> boards with PHYs at 0x1f from working properly.  Instead, scan the bus when
> it comes up, and find an address that doesn't have a PHY on it.  The TBI PHY
> configuration code then trusts that the value in TBIPA is either safe, or
> doesn't matter (ie - it's not an active bus with other PHYs).
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

applied


