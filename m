From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] p54: add null pointer check before releasing socket
 buffer
Date: Mon, 10 Apr 2017 07:03:37 -0700 (PDT)
Message-ID: <20170410.070337.626219013449399798.davem@davemloft.net>
References: <1491801800-4371-1-git-send-email-mhjungk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chunkeey@googlemail.com, netdev@vger.kernel.org
To: mhjungk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753576AbdDJODm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:03:42 -0400
In-Reply-To: <1491801800-4371-1-git-send-email-mhjungk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Myungho Jung <mhjungk@gmail.com>
Date: Sun,  9 Apr 2017 22:23:20 -0700

> Kernel panic is caused by trying to dereference null pointer. Check if
> the pointer is null before freeing space.
> 
> Signed-off-by: Myungho Jung <mhjungk@gmail.com>

Your tests are backwards, you therefore did not test your change.
In fact, your change is adding a memory leak.

It also calls into question whether there is a problem in the
first place.  What "panic" or crash did you actually see?
