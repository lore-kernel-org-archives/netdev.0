From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] RDS: TCP: socket locking RDS packet assembly
 fixes
Date: Tue, 07 Jun 2016 15:10:32 -0700 (PDT)
Message-ID: <20160607.151032.2112416864826499956.davem@davemloft.net>
References: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445AbcFGWKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:10:33 -0400
In-Reply-To: <cover.1465071319.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sat,  4 Jun 2016 13:59:57 -0700

> This three part patchset fixes bugs in synchronization between
> rds_tcp_accept_one() and the rds-tcp send/recv path.
> 
> Patch 1 ensures that the lock_sock() is taken appropriately
> and the RDS datagram reassembly state is reset  to synchronize
> with the receive path.
> 
> Patch 2 ensures that partially sent RDS datagrams will get
> retransmitted after rds_tcp_accept_one() switches sockets.
> 
> Patch 3 fixes a race window which would prematurely re-enable
> rds_send_xmit() before the rds_tcp_connection setup has been
> completed in rds_tcp_accept_one().

Series applied, thank you.
