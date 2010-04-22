From: David Miller <davem@davemloft.net>
Subject: Re: [patch] rdma: potential ERR_PTR dereference
Date: Thu, 22 Apr 2010 15:57:54 -0700 (PDT)
Message-ID: <20100422.155754.233400086.davem@davemloft.net>
References: <20100422095527.GQ29647@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52278
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753565Ab0DVW5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 18:57:49 -0400
In-Reply-To: <20100422095527.GQ29647@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 22 Apr 2010 11:55:27 +0200

> In the original code, the "goto out" calls "rdma_destroy_id(cm_id);"
> That isn't needed here and would cause problems because "cm_id" is an 
> ERR_PTR.  The new code just returns directly.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
