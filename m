From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Allow cascading to work with 6131 chip
Date: Mon, 20 Jun 2011 14:18:50 -0700 (PDT)
Message-ID: <20110620.141850.39278689858002609.davem@davemloft.net>
References: <1308602433-31320-1-git-send-email-barry@grussling.com>
	<1308602433-31320-2-git-send-email-barry@grussling.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org
To: barry@grussling.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab1FTVSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:18:53 -0400
In-Reply-To: <1308602433-31320-2-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>
Date: Mon, 20 Jun 2011 13:40:33 -0700

> ---
>  net/dsa/mv88e6131.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
> index 45f7411..1a1d1d1 100644
> --- a/net/dsa/mv88e6131.c
> +++ b/net/dsa/mv88e6131.c
> @@ -118,10 +118,14 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
>  	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1100) | 0x00f0);
>  
>  	/*
> -	 * Disable cascade port functionality, and set the switch's
> +	 * Disable cascade port functionality unless this device is
> +    * used in a cascade configuration, and set the switch's

This screws up the formatting, please don't do this.

The line is not aligned properly, it uses spaces instead of
TAB characters, etc. etc. etc.
