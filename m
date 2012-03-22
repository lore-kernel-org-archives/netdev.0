From: David Miller <davem@davemloft.net>
Subject: Re: [patch] RDS: use gfp flags from caller in conn_alloc()
Date: Thu, 22 Mar 2012 19:30:55 -0400 (EDT)
Message-ID: <20120322.193055.1929591502119781703.davem@davemloft.net>
References: <20120322064409.GE7369@elgon.mountain>
	<4F6B4316.5050508@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942Ab2CVXbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 19:31:00 -0400
In-Reply-To: <4F6B4316.5050508@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Date: Thu, 22 Mar 2012 10:19:50 -0500

> On 3/22/2012 1:44 AM, Dan Carpenter wrote:
>> We should be using the gfp flags the caller specified here, instead of
>> GFP_KERNEL.  I think this might be a bugfix, depending on the value of
>> "sock->sk->sk_allocation" when we call rds_conn_create_outgoing() in
>> rds_sendmsg().  Otherwise, it's just a cleanup.
>>
>> Signed-off-by: Dan Carpenter<dan.carpenter@oracle.com>
> Acked-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>

Applied.
