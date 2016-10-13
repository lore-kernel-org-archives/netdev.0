From: David Miller <davem@davemloft.net>
Subject: Re: [patch] liquidio: CN23XX: fix a loop timeout
Date: Thu, 13 Oct 2016 12:13:04 -0400 (EDT)
Message-ID: <20161013.121304.1793021152439393574.davem@davemloft.net>
References: <20161013085657.GL16198@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20161013085657.GL16198@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 13 Oct 2016 11:56:57 +0300

> This is supposed to loop 1000 times and then give up.  The problem is
> it's a post-op and after the loop we test if "loop" is zero when really
> it would be -1.  Fix this by making it a pre-op.
> 
> Fixes: 1b7c55c4538b ("liquidio: CN23XX queue manipulation")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
