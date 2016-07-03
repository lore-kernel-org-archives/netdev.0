From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH] RDS: fix rds_tcp_init() error path
Date: Sun, 3 Jul 2016 07:21:15 -0400
Message-ID: <20160703112105.GA32174@oracle.com>
References: <1467536094-23722-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, davem@davemloft.net,
	rds-devel@oss.oracle.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26158 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbcGCLVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 07:21:25 -0400
Content-Disposition: inline
In-Reply-To: <1467536094-23722-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> If register_pernet_subsys() fails, we shouldn't try to call
> unregister_pernet_subsys().

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
