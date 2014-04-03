From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ti: fix CPTS driver build on arm
Date: Thu, 03 Apr 2014 11:25:09 -0400 (EDT)
Message-ID: <20140403.112509.2216291933293306098.davem@davemloft.net>
References: <1396402008-3462-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, richardcochran@gmail.com,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbaDCPXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 11:23:36 -0400
In-Reply-To: <1396402008-3462-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue,  1 Apr 2014 18:26:48 -0700

> fix build errors:
> drivers/net/ethernet/ti/cpts.c:266:12: error: 'ETH_HLEN' undeclared (first use in this function)
> drivers/net/ethernet/ti/cpts.c:276:23: error: 'VLAN_HLEN' undeclared (first use in this function)
> 
> Fixes: 408eccce3204 ("net: ptp: move PTP classifier in its own file")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Suggested-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
