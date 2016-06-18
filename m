From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] RDS: TCP: rds_tcp_accept_one() should transition
 socket from RESETTING to UP
Date: Fri, 17 Jun 2016 22:30:17 -0700 (PDT)
Message-ID: <20160617.223017.2174379015884894849.davem@davemloft.net>
References: <20160617201212.GC29044@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbcFRFaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 01:30:18 -0400
In-Reply-To: <20160617201212.GC29044@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 17 Jun 2016 16:12:12 -0400

> The state of the rds_connection after rds_tcp_reset_callbacks() would
> be RDS_CONN_RESETTING and this is the value that should be passed
> by rds_tcp_accept_one()  to rds_connect_path_complete() to transition
> the socket to RDS_CONN_UP.
> 
> Fixes: b5c21c0947c1 ("RDS: TCP: fix race windows in send-path quiescence
> by rds_tcp_accept_one()")
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied.
