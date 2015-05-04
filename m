From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/rds: Fix new sparse warning
Date: Mon, 04 May 2015 15:23:35 -0400 (EDT)
Message-ID: <20150504.152335.2023539217751495154.davem@davemloft.net>
References: <1430754698-247482-1-git-send-email-david.ahern@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	shamir.rabinovitch@oracle.com
To: david.ahern@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbEDTXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 15:23:37 -0400
In-Reply-To: <1430754698-247482-1-git-send-email-david.ahern@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <david.ahern@oracle.com>
Date: Mon,  4 May 2015 11:51:38 -0400

> c0adf54a109 introduced new sparse warnings:
>   CHECK   /home/dahern/kernels/linux.git/net/rds/ib_cm.c
> net/rds/ib_cm.c:191:34: warning: incorrect type in initializer (different base types)
> net/rds/ib_cm.c:191:34:    expected unsigned long long [unsigned] [usertype] dp_ack_seq
> net/rds/ib_cm.c:191:34:    got restricted __be64 <noident>
> net/rds/ib_cm.c:194:51: warning: cast to restricted __be64
> 
> The temporary variable for sequence number should have been declared as __be64
> rather than u64. Make it so.
> 
> Signed-off-by: David Ahern <david.ahern@oracle.com>

Applied, thanks David.
