From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] fs_enet: Remove dead code
Date: Wed, 22 Apr 2009 16:30:58 -0500
Message-ID: <49EF8C92.8050403@freescale.com>
References: <1240435170-5183-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:49903 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbZDVVbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 17:31:18 -0400
In-Reply-To: <1240435170-5183-1-git-send-email-galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> @@ -318,32 +314,6 @@ static void restart(struct net_device *dev)
>  	/*
>  	 * adjust to speed (only for DUET & RMII)
>  	 */
> -#ifdef CONFIG_DUET
> -	if (fpi->use_rmii) {

Please remove the comment that goes with the code being removed.

Otherwise, ACK.

-Scott
