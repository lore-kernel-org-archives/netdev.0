From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] rds-tcp: sock_graft() leak
Date: Sat, 08 Jul 2017 11:17:04 +0100 (WEST)
Message-ID: <20170708.111704.1692315804267544511.davem@davemloft.net>
References: <cover.1499352757.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41132 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752555AbdGHKRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 06:17:38 -0400
In-Reply-To: <cover.1499352757.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu,  6 Jul 2017 08:15:05 -0700

> Following up on the discussion at
>   https://www.spinics.net/lists/netdev/msg442859.html
> - make rds_tcp_accept_one() call sock_create_lite()
> - add a WARN_ON() to sock_graft() 
> 
> Tested by running an infinite while() loop that does
> (module-load; rds-stress; module-unload) and monitors
> TCP slabinfo while the test is running.

This looks great, thanks for following up on this.

Series applied and queued up for -stable.
