From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 RFC net-next] net/vxlan: Fix kernel unaligned access
 in __vxlan_find_mac
Date: Sat, 18 Jul 2015 22:23:42 -0700 (PDT)
Message-ID: <20150718.222342.2096520856648637537.davem@davemloft.net>
References: <1437174422.2495.75.camel@perches.com>
	<20150717.181825.641987192390100037.davem@davemloft.net>
	<1437242786.24289.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbbGSFXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2015 01:23:43 -0400
In-Reply-To: <1437242786.24289.11.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 18 Jul 2015 11:06:26 -0700

> As it's not fatal, naybe the sparc64 message should be
> KERN_DEBUG/pr_debug.

It's not fatal insofar as it doesn't crash the system.

But performance wise is _IS_ fatal, and I want the kernel to bark
at the user so that they report the issue or fix it sooner rather
than later.
