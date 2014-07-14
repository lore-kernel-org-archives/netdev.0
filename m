From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 3/6] ethernet: amd: dynamic debug fixes
Date: Mon, 14 Jul 2014 01:06:06 -0700
Message-ID: <1405325166.9132.40.camel@joe-AO725>
References: <1405319147-5212-1-git-send-email-varkabhadram@gmail.com>
	 <1405319147-5212-4-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas.Lendacky@amd.com,
	geert+renesas@linux-m68k.org, ebiederm@xmission.com,
	macro@linux-mips.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0097.hostedemail.com ([216.40.44.97]:59071 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750943AbaGNIGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 04:06:11 -0400
In-Reply-To: <1405319147-5212-4-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-14 at 11:55 +0530, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
[]
> diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
[]
> @@ -501,8 +501,7 @@ static int amd8111e_restart(struct net_device *dev)
>  
>  	/* Enable interrupt coalesce */
>  	if(lp->options & OPTION_INTR_COAL_ENABLE){
> -		printk(KERN_INFO "%s: Interrupt Coalescing Enabled.\n",
> -								dev->name);
> +		netdev_info(dev, "Interrupt Coalescing Enabled");

This needs a terminating newlines.
