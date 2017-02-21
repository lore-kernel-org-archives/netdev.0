From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] net: sock: Use USEC_PER_SEC macro
 instead of literal 1000000
Date: Tue, 21 Feb 2017 12:26:40 -0500 (EST)
Message-ID: <20170221.122640.1790844289388833683.davem@davemloft.net>
References: <1487668159-4720-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, soheil@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753016AbdBUR0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:26:42 -0500
In-Reply-To: <1487668159-4720-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Tue, 21 Feb 2017 17:09:19 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The USEC_PER_SEC is used once in sock_set_timeout as the max value of
> tv_usec. But there are other similar codes which use the literal
> 1000000 in this file.
> It is minor cleanup to keep consitent.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied, thank you.
