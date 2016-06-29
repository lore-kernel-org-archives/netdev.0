From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qed: Protect the doorbell BAR with the write
 barriers.
Date: Wed, 29 Jun 2016 08:16:18 -0400 (EDT)
Message-ID: <20160629.081618.2206817138199595643.davem@davemloft.net>
References: <1467114363-16948-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbcF2MQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 08:16:45 -0400
In-Reply-To: <1467114363-16948-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Tue, 28 Jun 2016 07:46:03 -0400

> SPQ doorbell is currently protected with the compilation barrier. Under the
> stress scenarios, we may get into a state where (due to the weak ordering)
> several ramrod doorbells were written to the BAR with an out-of-order
> producer values. Need to change the barrier type to a write barrier to make
> sure that the write buffer is flushed after each doorbell.
> 
> Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

Applied.
