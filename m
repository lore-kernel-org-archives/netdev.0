From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net] core: Don't attempt to load the "" driver.
Date: Tue, 09 Sep 2014 17:24:10 -0700 (PDT)
Message-ID: <20140909.172410.519439746131615877.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D174862E0@AcuExch.aculab.com>
	<20140905.143241.114624370748725493.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D1748BC57@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaIJAYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:24:11 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1748BC57@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 8 Sep 2014 13:23:33 +0000

> This whole 'try to load the module' path should be predicated on
> 'interface not found'.

And that's the first thing dev_load() does, it tries to look up the
device by name, and only does the module load attempt if that fails.

Nobody cares if the module load itself actually fails, dev_load()
returns void after all.
