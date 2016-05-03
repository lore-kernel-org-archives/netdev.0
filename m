From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] RDS: TCP: sychronization during connection
 startup
Date: Tue, 03 May 2016 16:05:04 -0400 (EDT)
Message-ID: <20160503.160504.1381876048546522908.davem@davemloft.net>
References: <cover.1462212462.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbcECUFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:05:07 -0400
In-Reply-To: <cover.1462212462.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon,  2 May 2016 11:24:50 -0700

> This patch series ensures that the passive (accept) side of the
> TCP connection used for RDS-TCP is correctly synchronized with
> any concurrent active (connect) attempts for a given pair of peers.
> 
> Patch 1 in the series makes sure that the t_sock in struct 
> rds_tcp_connection is only reset after any threads in rds_tcp_xmit
> have completed (otherwise a null-ptr deref may be encountered). 
> Patch 2 synchronizes rds_tcp_accept_one() with the rds_tcp*connect()
> path.
> 
> v2: review comments from Santosh Shilimkar, other spelling corrections

Series applied, thanks.
