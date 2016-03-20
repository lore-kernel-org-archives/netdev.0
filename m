From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: do not update a_rwnd if we are not issuing a sack
Date: Sun, 20 Mar 2016 16:31:45 -0400 (EDT)
Message-ID: <20160320.163145.1907195712733416950.davem@davemloft.net>
References: <1458337159-22792-3-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbcCTUbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 16:31:47 -0400
In-Reply-To: <1458337159-22792-3-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 18 Mar 2016 18:39:18 -0300

> The SACK can be lost pretty much elsewhere, but if its allocation fail,
> we know we are not sending it, so it is better to revert a_rwnd to its
> previous value as this may give it a chance to issue a window update
> later.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
