From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 42012] New: regression on 2.6.39.3 with socket/bind;
 still there in 3.0.4
Date: Tue, 30 Aug 2011 14:07:33 -0400 (EDT)
Message-ID: <20110830.140733.146208373221522199.davem@davemloft.net>
References: <20110830084742.26c72c20@nehalam.ftrdhcpuser.net>
	<1314720708.2935.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848Ab1H3SIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 14:08:11 -0400
In-Reply-To: <1314720708.2935.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Aug 2011 18:11:48 +0200

> Yep, we should relax the check and accept AF_UNSPEC.

I guess we'll have to do this, but I just can't bring myself to accept
that we can just do zero validation of what the user is passing us,
see an AF_UNSPEC, and say "yeah it's fine to assume there's an ipv4
address in there."
