From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] RDS: TCP: unregister_netdevice_notifier() in error
 path of rds_tcp_init_net
Date: Fri, 02 Dec 2016 13:30:42 -0500 (EST)
Message-ID: <20161202.133042.668824120029340797.davem@davemloft.net>
References: <1480596283-204869-1-git-send-email-sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754829AbcLBSao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:30:44 -0500
In-Reply-To: <1480596283-204869-1-git-send-email-sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu,  1 Dec 2016 04:44:43 -0800

> If some error is encountered in rds_tcp_init_net, make sure to
> unregister_netdevice_notifier(), else we could trigger a panic
> later on, when the modprobe from a netns fails.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied, thank you.
