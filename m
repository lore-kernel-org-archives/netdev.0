From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Re: [patch] RDS: use gfp flags from caller in conn_alloc()
Date: Thu, 22 Mar 2012 10:19:50 -0500
Message-ID: <4F6B4316.5050508@oracle.com>
References: <20120322064409.GE7369@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:22232 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135Ab2CVPTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 11:19:55 -0400
In-Reply-To: <20120322064409.GE7369@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/2012 1:44 AM, Dan Carpenter wrote:
> We should be using the gfp flags the caller specified here, instead of
> GFP_KERNEL.  I think this might be a bugfix, depending on the value of
> "sock->sk->sk_allocation" when we call rds_conn_create_outgoing() in
> rds_sendmsg().  Otherwise, it's just a cleanup.
>
> Signed-off-by: Dan Carpenter<dan.carpenter@oracle.com>
Acked-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
