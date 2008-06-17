From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] [Rev2] MPC5121 FEC support
Date: Tue, 17 Jun 2008 14:33:28 -0500
Message-ID: <48581188.90102@freescale.com>
References: <1213729717-26688-1-git-send-email-jrigby@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jeff@garzik.org, netdev@vger.kernel.org
To: John Rigby <jrigby@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35718 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756052AbYFQTdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 15:33:36 -0400
In-Reply-To: <1213729717-26688-1-git-send-email-jrigby@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Rigby wrote:
>  config FS_ENET
>         tristate "Freescale Ethernet Driver"
> -       depends on CPM1 || CPM2
> +       depends on CPM1 || CPM2 || FS_ENET_MPC5121_FEC
>         select MII
>         select PHYLIB
>  
> +config FS_ENET_MPC5121_FEC
> +	bool "Freescale MPC512x FEC driver"
> +	depends on PPC_MPC512x
> +	select FS_ENET
> +	select PPC_CPM_NEW_BINDING
> +	default y

No default y.

-Scott
