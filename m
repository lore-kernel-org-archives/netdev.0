From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] RDMA/cma: Add IPv6 support for iWARP.
Date: Fri, 07 Jun 2013 15:01:14 -0700 (PDT)
Message-ID: <20130607.150114.1324134043100965304.davem@davemloft.net>
References: <1370505201-29961-1-git-send-email-vipul@chelsio.com>
	<1370505201-29961-2-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	roland@purestorage.com, divy@chelsio.com, dm@chelsio.com,
	swise@opengridcomputing.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	tom@opengridcomputing.com, faisal.latif@intel.com,
	akpm@linux-foundation.org, sasha.levin@oracle.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab3FGWBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 18:01:15 -0400
In-Reply-To: <1370505201-29961-2-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please use local variables for the sockaddr_in{,6} pointers instead of
casting over and over and over and over again.

Thanks.
