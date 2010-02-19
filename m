From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] greth: some driver cleanups
Date: Fri, 19 Feb 2010 13:18:19 -0800 (PST)
Message-ID: <20100219.131819.27458744.davem@davemloft.net>
References: <20100219125148.GA6598@psychotron.redhat.com>
	<20100219150051.GA12393@coldcone>
	<20100219152502.GD6598@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kirjanov@gmail.com, kristoffer@gaisler.com, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754200Ab0BSVSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 16:18:03 -0500
In-Reply-To: <20100219152502.GD6598@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 19 Feb 2010 16:25:02 +0100

> Fri, Feb 19, 2010 at 04:00:52PM CET, kirjanov@gmail.com wrote:
>>On Fri, Feb 19, 2010 at 13:51 +0100, Jiri Pirko wrote:
>>> 
>>> <snip>
>>> >>@@ -1031,7 +1029,7 @@ static void greth_set_multicast_list(struct net_device *dev)
>>> >> 			return;
>>> >> 		}
>>> >> 
>>> >>-		if (dev->mc_count == 0) {
>>> >>+		if (!netdev_mc_count(dev)) {
>>> also please use netdev_mc_empty() here.
>>Some driver cleanups:
>>* convert to use phy_find_first/phy_direct_connect
>>* convert to use netdev_mc_* helpers
>>* fixed missing validate_addr hook
>>* removed netdev_priv castings
>>
>>Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
 ...
> Looks good.
> 
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks everyone.
