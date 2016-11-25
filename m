From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: fix memory leak on txq_info
Date: Fri, 25 Nov 2016 16:10:58 -0500 (EST)
Message-ID: <20161125.161058.2283539123524395654.davem@davemloft.net>
References: <20161123110244.16111-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52434 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbcKYVLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 16:11:23 -0500
In-Reply-To: <20161123110244.16111-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Wed, 23 Nov 2016 11:02:44 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> Currently if txq_info->uldtxq cannot be allocated then
> txq_info->txq is being kfree'd (which is redundant because it
> is NULL) instead of txq_info. Fix this by instead kfree'ing
> txq_info.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, but Colin you _really_ need to start properly marking your
networking patch submissions by indicating in the subject which
tree your change is for.  In this case I figured out it was
net-next, but you must say this explicitly in the Subject line
via "Subject: [PATCH net-next] ..."

Thanks.
