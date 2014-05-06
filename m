From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/24] net, diet: Make GRO offload optional
Date: Mon, 05 May 2014 23:01:18 -0400 (EDT)
Message-ID: <20140505.230118.938429615465621236.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-14-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933739AbaEFDBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 23:01:19 -0400
In-Reply-To: <1399328773-6531-14-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:26:02 -0700

> It's not needed on small systems.

On the contrary, I would expect the performance gains from
batching the packet receive path to be even larger on slow
small computers.
