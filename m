From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: do not leak chunks that are sent to unconfirmed
 paths
Date: Sun, 20 Mar 2016 16:31:31 -0400 (EDT)
Message-ID: <20160320.163131.1842856580709650450.davem@davemloft.net>
References: <1458337159-22792-4-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcCTUbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 16:31:39 -0400
In-Reply-To: <1458337159-22792-4-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 18 Mar 2016 18:39:19 -0300

> Currently, if a chunk is scheduled to be sent through a transport that
> is currently unconfirmed, it will be leaked as it is dequeued from outq
> and is not re-queued nor freed.
> 
> As I'm not aware of any situation that may lead to this situation, I'm
> fixing this by freeing the chunk and also logging a trace so that we can
> fix the other bug if it ever happens.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
