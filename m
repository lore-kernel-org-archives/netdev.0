From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Sun, 22 Jul 2012 17:15:53 -0700 (PDT)
Message-ID: <20120722.171553.2139258607165498367.davem@davemloft.net>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com>
	<500BD558.2060803@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klebers@linux.vnet.ibm.com, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	cascardo@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39431 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab2GWAP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 20:15:56 -0400
In-Reply-To: <500BD558.2060803@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 22 Jul 2012 13:26:32 +0300

> is there anything in the code you added which maybe implicitly
> assumes PPC arch?

He implemented support for a standard PCI API in the kernel, he
happened to test it on a particular platform, and I think that's
the long and short of it.
