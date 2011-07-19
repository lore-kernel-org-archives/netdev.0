From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/45] Update bna driver version to 3.0.2.0
Date: Mon, 18 Jul 2011 18:58:05 -0700 (PDT)
Message-ID: <20110718.185805.413849001475627611.davem@davemloft.net>
References: <1310977178-312-1-git-send-email-rmody@brocade.com>
	<20110718.012639.1253140864720328605.davem@davemloft.net>
	<E5313AF6F2BFD14293E5FD0F94750F86A83BDF4A00@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54487 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab1GSB7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 21:59:19 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A83BDF4A00@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Mon, 18 Jul 2011 17:48:03 -0700

> We wanted to avoid submitting developing code that could break
> upstream driver due to partial changes.

So what you're saying is that if only some of the patches are applied
the driver will not work properly?

That's not allowed either, your set of changes must be fully
bisectable meaning that at any point in the series the driver
must still compile and work properly.

You guys need to sort out how you guys submit your changes.

When you have 4 patches ready to go, post them immediately.

Because if there are fundamental problem with the first 4,
everything else that depends upon them will need to change.
