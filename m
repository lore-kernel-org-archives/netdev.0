From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] dm9000: add checksum offload support
Date: Sun, 5 Jul 2009 13:29:30 +0200
Message-ID: <20090705112930.GA7698@electric-eye.fr.zoreil.com>
References: <4A503CC3.4050205@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux-arm@fluff.org>,
	Yeasah Pell <yeasah@comrex.com>, netdev@vger.kernel.org
To: Mike Rapoport <mike@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48162 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754453AbZGEL0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 07:26:51 -0400
Content-Disposition: inline
In-Reply-To: <4A503CC3.4050205@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Rapoport <mike@compulab.co.il> :
[...]
> @@ -743,6 +789,31 @@ static void dm9000_timeout(struct net_device *dev)
>  	spin_unlock_irqrestore(&db->lock, flags);
>  }
> 
> +static void dm9000_send_packet(struct net_device *dev,
[...]
> +	dev->trans_start = jiffies;	/* save the time stamp */

trans_start updating is done in core and can be removed.

-- 
Ueimor
