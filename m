From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Fix incorrect setting of tunnel offload
 flag in netdev features
Date: Thu, 18 Dec 2014 12:51:48 -0500 (EST)
Message-ID: <20141218.125148.1926282616065027550.davem@davemloft.net>
References: <1418963418-18792-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sriharsha.basavapatna@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbaLRRvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:51:50 -0500
In-Reply-To: <1418963418-18792-1-git-send-email-sriharsha.basavapatna@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Date: Fri, 19 Dec 2014 10:00:18 +0530

> An earlier commit to resolve an issue with encapsulation offloads missed
> setting a bit in the outer netdev features flag. This results in loss of TSO
> feature on a VxLAN interface.
> 
> Fixes: 630f4b70 ("Export tunnel offloads only when a VxLAN tunnel is created")
> 
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>

Applied, thanks.
