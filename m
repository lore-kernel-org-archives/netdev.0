From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: DM9000: Use delayed work to update MII PHY state
Date: Thu, 8 May 2008 13:11:02 -0700
Message-ID: <20080508131102.2c8c3cab.akpm@linux-foundation.org>
References: <20080428151309.GA30439@fluff.org.uk>
	<4820865F.70703@garzik.org>
	<20080508103642.GE30439@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, ben-linux@fluff.org, netdev@vger.kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49523 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765397AbYEHUMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 16:12:16 -0400
In-Reply-To: <20080508103642.GE30439@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 May 2008 11:36:42 +0100
Ben Dooks <ben-linux@fluff.org> wrote:

> @@ -879,6 +903,8 @@ dm9000_stop(struct net_device *ndev)
>  	if (netif_msg_ifdown(db))
>  		dev_dbg(db->dev, "shutting down %s\n", ndev->name);
>  
> +	cancel_delayed_work(&db->phy_poll);

I think this should be cancel_delayed_work_sync().
