From: David Miller <davem@davemloft.net>
Subject: Re: [net-next][PATCH] RDS: keep data type consistent in the user
 visible header
Date: Mon, 20 Feb 2017 10:19:51 -0500 (EST)
Message-ID: <20170220.101951.663166903772216217.davem@davemloft.net>
References: <1487387747-5324-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753010AbdBTPTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:19:53 -0500
In-Reply-To: <1487387747-5324-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Fri, 17 Feb 2017 19:15:47 -0800

> From: Santosh Shilimkar <ssantosh@kernel.org>
> 
> rds.h is exported to /usr/include/rds.h,  so u8, u64 leads to
> errors like below.
> 
> /usr/include/linux/rds.h:197: error: expected specifier-qualifier-list before 'u8'
> /usr/include/linux/rds.h:202: error: expected specifier-qualifier-list before 'u8'
> 
> Fix it by following same types as rest of the user header.
> 
> Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Signed-off-by: Santosh Shilimkar <ssantosh.shilimkar@oracle.org>

The correct fix it to use "__u8", "__u64", etc.
