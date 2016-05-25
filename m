From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: on MC reset, clear PIO buffer linkage in TXQs
Date: Wed, 25 May 2016 12:44:50 -0700 (PDT)
Message-ID: <20160525.124450.1355491012650035692.davem@davemloft.net>
References: <57449520.5070205@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbcEYTow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 15:44:52 -0400
In-Reply-To: <57449520.5070205@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 24 May 2016 18:53:36 +0100

> Otherwise, if we fail to allocate new PIO buffers, our TXQs will try to
> use the old ones, which aren't there any more.
> 
> Fixes: 183233bec810 "sfc: Allocate and link PIO buffers; map them with write-combining"
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied and queued up for -stable.
