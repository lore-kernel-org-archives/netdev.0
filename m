From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: add option for silent port knocking with
 integrity protection
Date: Wed, 11 Dec 2013 15:01:37 -0500 (EST)
Message-ID: <20131211.150137.368953964178408437.davem@davemloft.net>
References: <52A75EF8.3010308@in.tum.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	knock@gnunet.org, jacob@appelbaum.net
To: grothoff@in.tum.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab3LKUBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:01:40 -0500
In-Reply-To: <52A75EF8.3010308@in.tum.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Grothoff <grothoff@in.tum.de>
Date: Tue, 10 Dec 2013 19:35:36 +0100

> Only NAT implementations that change the SQN are not supported
> (those should be rare, but we have no hard data on this).

Even Linux's netfilter can and does do this, it is absolutely necessary
for tracking SIP and FTP protocols, and it's also used in our virtual
server load balancing modules.
