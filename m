From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net] tls: return -EFAULT if copy_to_user() fails
Date: Fri, 23 Jun 2017 14:20:30 -0400 (EDT)
Message-ID: <20170623.142030.1486260738446581677.davem@davemloft.net>
References: <20170623101544.c5bvwe5cd6e46bd5@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davejwatson@fb.com, aviadye@mellanox.com, ilyal@mellanox.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754327AbdFWSUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 14:20:33 -0400
In-Reply-To: <20170623101544.c5bvwe5cd6e46bd5@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 23 Jun 2017 13:15:44 +0300

> The copy_to_user() function returns the number of bytes remaining but we
> want to return -EFAULT here.
> 
> Fixes: 3c4d7559159b ("tls: kernel TLS support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Dan, I happened to realize that tls is only in net-next, but please
indicate the target tree properly in your Subject lines in the
future.

Applied, thanks.
