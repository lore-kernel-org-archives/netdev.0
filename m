From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net] core: Don't attempt to load the "" driver.
Date: Wed, 10 Sep 2014 13:06:05 -0700 (PDT)
Message-ID: <20140910.130605.530345860296154707.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D1748BC57@AcuExch.aculab.com>
	<20140909.172410.519439746131615877.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D1748EC90@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbaIJUGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 16:06:06 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1748EC90@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 10 Sep 2014 08:50:50 +0000

> I actually wonder when the module load is useful - must be useful
> sometimes, otherwise it wouldn't have been added.

Just grep for things like MODULE_ALIAS_NETDEV(...) for the legacy cases
where this can still be used.  Largely it's for tunneling devices.
