From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] net: remove trans_start from struct
 net_device
Date: Wed, 04 May 2016 14:17:20 -0400 (EDT)
Message-ID: <20160504.141720.294556689238527670.davem@davemloft.net>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754689AbcEDSRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 14:17:22 -0400
In-Reply-To: <1462285862-30946-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  3 May 2016 16:30:57 +0200

> We currently have two instances for trans_start, once in
> net_device and once in netdev_queue.
> 
> This series removes trans_start from net_device.
> Updates to dev->trans_start are replaced with updates to netdev queue 0.

Series applied, of course sans patch #1 which you resubmitted separately.

Thanks.
