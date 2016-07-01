From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] RDS:TCP data structure changes for
 multipath support
Date: Fri, 01 Jul 2016 16:46:07 -0400 (EDT)
Message-ID: <20160701.164607.2266533461886636739.davem@davemloft.net>
References: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbcGAUqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 16:46:11 -0400
In-Reply-To: <cover.1467322344.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 30 Jun 2016 16:11:09 -0700

> The second installment of changes to enable multipath support in
> RDS-TCP. This series implements the changes in rds-tcp so that the 
> rds_conn_path has a pointer to the rds_tcp_connection in cp_transport_data.
> Struct rds_tcp_connection keeps track of the inet_sk per path in
> t_sock. The ->sk_user_data in turn is a pointer to the rds_conn_path.
> With this set of changes, rds_tcp has the needed plumbing to handle
> multiple paths(socket) per rds_connection.

Series applied, thanks.
