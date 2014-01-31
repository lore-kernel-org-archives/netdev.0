From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/vxlan: Go over all candidate streams for GRO
 matching
Date: Thu, 30 Jan 2014 16:26:35 -0800 (PST)
Message-ID: <20140130.162635.33451911032333682.davem@davemloft.net>
References: <1391011810-10682-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753635AbaAaA0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 19:26:35 -0500
In-Reply-To: <1391011810-10682-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 29 Jan 2014 18:10:10 +0200

> The loop in vxlan_gro_receive() over the current set of candidates for 
> coalescing was wrongly aborted once a match was found. In rare cases,
> this can cause a false-positives matching in the next layer GRO checks.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied.
