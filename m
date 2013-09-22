From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API and advertise
 this feature
Date: Sun, 22 Sep 2013 07:55:23 -0700
Message-ID: <1379861723.3431.10.camel@edumazet-glaptop>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	Anirban Chakraborty <abchak@juniper.net>,
	Ian Campbell <ian.campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:51756 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab3IVOz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 10:55:26 -0400
Received: by mail-ob0-f169.google.com with SMTP id wp4so2728589obc.14
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 07:55:25 -0700 (PDT)
In-Reply-To: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-09-21 at 17:05 +0100, Wei Liu wrote:
> Anirban was seeing netfront received MTU size packets, which downgraded
> throughput. The following patch makes netfront use GRO API which
> improves throughput for that case.

> -	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
> +	netdev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO |
> +				  NETIF_F_GRO;


This part is not needed.
