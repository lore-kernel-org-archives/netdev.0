From: Andy Grover <andy.grover@oracle.com>
Subject: Re: [patch] rdma: potential ERR_PTR dereference
Date: Thu, 22 Apr 2010 10:28:31 -0700
Message-ID: <4BD0873F.4050704@oracle.com>
References: <20100422095527.GQ29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:30926 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab0DVR26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 13:28:58 -0400
In-Reply-To: <20100422095527.GQ29647@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
> In the original code, the "goto out" calls "rdma_destroy_id(cm_id);"
> That isn't needed here and would cause problems because "cm_id" is an 
> ERR_PTR.  The new code just returns directly.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Thanks, Dan.

Acked-by: Andy Grover <andy.grover@oracle.com>

-- Andy

