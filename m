From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] l2tp: fix data packet sequence number
 handling
Date: Thu, 10 May 2012 23:27:56 -0400 (EDT)
Message-ID: <20120510.232756.39316993733451277.davem@davemloft.net>
References: <1336642989-4785-1-git-send-email-jchapman@katalix.com>
	<1336642989-4785-2-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932399Ab2EKD17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:27:59 -0400
In-Reply-To: <1336642989-4785-2-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Thu, 10 May 2012 10:43:09 +0100

> If enabled, L2TP data packets have sequence numbers which a receiver
> can use to drop out of sequence frames or try to reorder them. The
> first frame has sequence number 0, but the L2TP code currently expects
> it to be 1. This results in the first data frame being handled as out
> of sequence.
> 
> This one-line patch fixes the problem.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied.
