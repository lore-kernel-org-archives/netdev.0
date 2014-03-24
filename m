From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: davinci_emac: Fix interrupt requests and
 error handling
Date: Mon, 24 Mar 2014 15:33:33 -0400 (EDT)
Message-ID: <20140324.153333.260738871320545801.davem@davemloft.net>
References: <ffba6fa2-5a11-41b0-a310-12250e104405@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	prabhakar.csengg@gmail.com, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com, jon@ringle.org,
	davinci-linux-open-source@linux.davincidsp.com
To: christian.riesch@omicron.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583AbaCXTdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 15:33:37 -0400
In-Reply-To: <ffba6fa2-5a11-41b0-a310-12250e104405@mary.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Riesch <christian.riesch@omicron.at>
Date: Mon, 24 Mar 2014 13:46:25 +0100

> since commit 6892b41d9701283085b655c6086fb57a5d63fa47 (Linux 3.11) the
> davinci_emac driver is broken. After doing ifconfig down, ifconfig up,
> requesting the interrupts for the driver fails. The interface remains dead
> until the board is rebooted.
> 
> The first patch in this patchset reverts commit
> 6892b41d9701283085b655c6086fb57a5d63fa47 partially and makes the driver
> useable again.
> 
> During the work on the first patch, a number of bugs in the error handling
> of the driver's ndo_open code were found. The second patch fixes these bugs.
> 
> I believe the first patch meets the rules for stable kernels, I therefore added
> the stable tag to this patch. The second patch is just cleanup, the code
> that is fixed by this patch is only executed in case of an error.

Series applied and patch #1 queued up for -stable, thanks!
