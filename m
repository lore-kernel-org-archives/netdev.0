From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] net_sched: actions - Add default lookup
Date: Sun, 03 Nov 2013 23:17:29 -0500 (EST)
Message-ID: <20131103.231729.12647956618590906.davem@davemloft.net>
References: <5270ECB5.2030601@mojatatu.com>
	<1383141605.4857.38.camel@edumazet-glaptop.roam.corp.google.com>
	<20131103.231232.1438716028901698864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, ebiederm@xmission.com,
	alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3KDERj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 23:17:39 -0500
In-Reply-To: <20131103.231232.1438716028901698864.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 03 Nov 2013 23:12:32 -0500 (EST)

> Right, and BUG() if we try to register and action with a NULL .lookup
> member.

I return an error, BUG() is too harsh.
