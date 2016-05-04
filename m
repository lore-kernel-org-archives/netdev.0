From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] bonding: update documentation section after
 dev->trans_start removal
Date: Wed, 04 May 2016 17:07:27 -0400 (EDT)
Message-ID: <20160504.170727.1944116843618607152.davem@davemloft.net>
References: <1462395107-18703-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43493 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbcEDVH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 17:07:29 -0400
In-Reply-To: <1462395107-18703-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  4 May 2016 22:51:47 +0200

> Drivers that use LLTX need to update trans_start of the netdev_queue.
> (Most drivers don't use LLTX; stack does this update if .ndo_start_xmit
>  returned TX_OK).
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
