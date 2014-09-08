From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dp83640: Make use of skb_queue_purge instead
 of reimplementing the code
Date: Mon, 08 Sep 2014 14:24:50 -0700 (PDT)
Message-ID: <20140908.142450.1267506394337564210.davem@davemloft.net>
References: <20140908152226.4202.72383.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724AbaIHVYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:24:50 -0400
In-Reply-To: <20140908152226.4202.72383.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 08 Sep 2014 11:25:34 -0400

> This change makes it so that dp83640_remove can use skb_queue_purge
> instead of looping through itself to flush any entries out of the queue.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks Alex.
