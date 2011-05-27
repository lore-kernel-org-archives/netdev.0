From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fixed missing fixup of sctp_local_addr_free
Date: Fri, 27 May 2011 13:40:04 -0400 (EDT)
Message-ID: <20110527.134004.1654129007987862831.davem@davemloft.net>
References: <1306517820-4793-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968Ab1E0Rl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 13:41:26 -0400
In-Reply-To: <1306517820-4793-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 27 May 2011 13:37:00 -0400

> commit 1231f0baa547a541a7481119323b7f964dda4788  Converted sctp to use
> kfree_rcu from sctp_local_addr_free but missed this one call point.  Fix it up
> accordingly.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

This has been fixed for several days now.

If you're using the net-next-2.6 tree, don't, when it's not active
it's just a dummy tree for Stephen Rothwell to pull into -next
and it will be rebuilt as soon as the merge window is over.
