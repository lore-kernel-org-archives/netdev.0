From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during
 softnet overflow
Date: Tue, 23 Apr 2013 19:15:40 -0400 (EDT)
Message-ID: <20130423.191540.217250507483659201.davem@davemloft.net>
References: <1366749094-5982-1-git-send-email-willemb@google.com>
	<20130423.184140.2020239496583590253.davem@davemloft.net>
	<1366758683.8964.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535Ab3DWXPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 19:15:43 -0400
In-Reply-To: <1366758683.8964.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Apr 2013 16:11:23 -0700

> I guess we should at least not include this code on !SMP builds

I think CONFIG_RPS already an appropriate guard for something like
this.  And it depends upon SMP et al.
