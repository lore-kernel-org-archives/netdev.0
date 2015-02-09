From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 00/17] tipc: new compat layer for the
 legacy NL API
Date: Mon, 09 Feb 2015 13:21:14 -0800 (PST)
Message-ID: <20150209.132114.285702672812314395.davem@davemloft.net>
References: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbbBIVVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 16:21:17 -0500
In-Reply-To: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Mon, 9 Feb 2015 09:50:02 +0100

> This is a compatibility / transcoding layer for the old netlink API.
> It relies on the new netlink API to collect data or perform actions
> (dumpit / doit).
> 
> The main benefit of this compat layer is that it removes a lot of
> complex code from the tipc core as only the new API needs to be able
> harness data or perform actions. I.e. the compat layer isn't concerned
> with locking or how the internal data-structures look. As long as the
> new API stays relatively intact the compat layer should be fine.
> 
> The main challenge in this compat layer is the randomness of the legacy
> API. Some commands send binary data and some send ASCII data, some are
> very picky in optimizing there buffer sizes and some just don't care.
> Most legacy commands put there data in a single TLV (data container) but some
> segment the data into multiple TLV's. This list of randomness goes on and on..

Series applied, thanks.
