From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] mlx4: Flexible (asymmetric) allocation of
 EQs and MSI-X vectors
Date: Thu, 13 Nov 2014 15:16:52 -0500 (EST)
Message-ID: <20141113.151652.1002359459440166533.davem@davemloft.net>
References: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933146AbaKMUQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 15:16:56 -0500
In-Reply-To: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 13 Nov 2014 14:45:26 +0200

> This series from Matan Barak is built as follows:
> 
> The 1st two patches fix small bugs w.r.t firmware spec. Next
> are two patches which do more re-factoring of the init/fini flow
> and a patch that adds support for the QUERY_FUNC firmware command,
> these are all pre-steps for the major patch of the series. In this
> patch (#6) we change the order of talking/querying the firmware
> and enabling SRIOV. This allows to remote worst-case assumption
> w.r.t the number of available MSI-X vectors and EQs per function.
> 
> The last patch easily enjoys this ordering change, to enable
> supports > 64 VFs over a firmware that allows for that.

Series applied, thank you.
