From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] rds: signedness bug
Date: Sun, 19 Sep 2010 11:59:53 -0700 (PDT)
Message-ID: <20100919.115953.260073665.davem@davemloft.net>
References: <20100918234224.GC6236@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753092Ab0ISS7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 14:59:34 -0400
In-Reply-To: <20100918234224.GC6236@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sun, 19 Sep 2010 01:42:25 +0200

> In the original code if the copy_from_user() fails in rds_rdma_pages()
> then the error handling fails and we get a stack trace from kmalloc().
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
