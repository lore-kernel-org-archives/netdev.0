From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] RDS: TCP: rds_tcp_accept_one() should transition
 socket from RESETTING to UP
Date: Fri, 17 Jun 2016 13:51:30 -0700
Message-ID: <6b8c05a3-bf6c-c2c2-70ef-91faa868ee60@oracle.com>
References: <20160617201212.GC29044@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17505 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156AbcFQUvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 16:51:50 -0400
In-Reply-To: <20160617201212.GC29044@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/17/2016 1:12 PM, Sowmini Varadhan wrote:
> The state of the rds_connection after rds_tcp_reset_callbacks() would
> be RDS_CONN_RESETTING and this is the value that should be passed
> by rds_tcp_accept_one()  to rds_connect_path_complete() to transition
> the socket to RDS_CONN_UP.
>
> Fixes: b5c21c0947c1 ("RDS: TCP: fix race windows in send-path quiescence
> by rds_tcp_accept_one()")
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
