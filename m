From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: do not leak initialized list.dev to userspace
Date: Fri, 18 Aug 2017 16:22:19 -0700 (PDT)
Message-ID: <20170818.162219.1082889879381171834.davem@davemloft.net>
References: <20170817221458.27040-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdHRXWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:22:20 -0400
In-Reply-To: <20170817221458.27040-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Thu, 17 Aug 2017 23:14:58 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> list.dev has not been initialized and so the copy_to_user is copying
> data from the stack back to user space which is a potential
> information leak. Fix this ensuring all of list is initialized to
> zero.
> 
> Detected by CoverityScan, CID#1357894 ("Uninitialized scalar variable")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied and queued up for -stable, thanks.
