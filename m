From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] esp6: fix incorrect null pointer check on xo
Date: Tue, 18 Apr 2017 13:12:53 -0400 (EDT)
Message-ID: <20170418.131253.2065320027211688167.davem@davemloft.net>
References: <20170418140653.8839-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754590AbdDRRM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:12:57 -0400
In-Reply-To: <20170418140653.8839-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Tue, 18 Apr 2017 15:06:53 +0100

Trimming the CC: list down to something that actually makes
sense.

> From: Colin Ian King <colin.king@canonical.com>
> 
> The check for xo being null is incorrect, currently it is checking
> for non-null, it should be checking for null.
> 
> Detected with CoverityScan, CID#1429349 ("Dereference after null check")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

At a minimum you should work to check that you are CC:'ing the person
who added the code you are fixing.  You can use "git blame" for this.

Also, Steffen, you need to add the new IPSEC offload files to the
MAINTAINERS entry for iPSEC.

Thank you.
