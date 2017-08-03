From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rds: reduce memory footprint for RDS when
 transport is RDMA
Date: Thu, 03 Aug 2017 09:28:19 -0700 (PDT)
Message-ID: <20170803.092819.659501620552888426.davem@davemloft.net>
References: <1501695271-146367-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
        santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdHCQ2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:28:20 -0400
In-Reply-To: <1501695271-146367-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed,  2 Aug 2017 10:34:31 -0700

> RDS over IB does not use multipath RDS, so the array
> of additional rds_conn_path structures is always superfluous
> in this case. Reduce the memory footprint of the rds module
> by making this a dynamic allocation predicated on whether
> the transport is mp_capable.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> Tested-by: Efrain Galaviz <efrain.galaviz@oracle.com>

Applied, thank you.
