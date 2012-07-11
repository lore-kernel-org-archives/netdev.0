From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Tue, 10 Jul 2012 21:13:04 -0700 (PDT)
Message-ID: <20120710.211304.1112522544390324120.davem@davemloft.net>
References: <1341978558.3265.6609.camel@edumazet-glaptop>
	<20120710.210221.559183284956265274.davem@davemloft.net>
	<1341979678.3265.6660.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43712 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680Ab2GKENF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 00:13:05 -0400
In-Reply-To: <1341979678.3265.6660.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Jul 2012 06:07:58 +0200

> I dont think this 8bytes alignment is possible with ip6tables.

Hmmm, wouldn't it make more sense to make ip6tables use a special
accessor than to penalize everyone?
