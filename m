From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] via-velocity : fix no link detection on boot
Date: Tue, 16 Jun 2009 22:50:20 +0200
Message-ID: <20090616205020.GB19349@electric-eye.fr.zoreil.com>
References: <1245184399-11890-1-git-send-email-rseguier@e-teleport.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Seguier Regis <rseguier@e-teleport.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47241 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752484AbZFPUsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 16:48:08 -0400
Content-Disposition: inline
In-Reply-To: <1245184399-11890-1-git-send-email-rseguier@e-teleport.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seguier Regis <rseguier@e-teleport.net> :
[...]
> @@ -989,8 +989,11 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
>  	if (ret < 0)
>  		goto err_iounmap;
>  
> -	if (velocity_get_link(dev))
> +	if (!velocity_get_link(dev))
> +	{
>  		netif_carrier_off(dev);

Ok but please do not put the curly brace on a proper line.

-- 
Ueimor
