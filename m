From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 v2 net-next] tcp cwnd undo refactor
Date: Sun, 06 Aug 2017 21:25:26 -0700 (PDT)
Message-ID: <20170806.212526.493468811013338187.davem@davemloft.net>
References: <20170804033852.97986-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, unlcsewsun@gmail.com,
        stephen@networkplumber.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdHGEZ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:25:27 -0400
In-Reply-To: <20170804033852.97986-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu,  3 Aug 2017 20:38:50 -0700

> This patch series consolidate similar cwnd undo functions
> implemented by various congestion control by using existing
> tcp socket state variable. The first patch fixes a corner
> case in of cwnd undo in Reno and HTCP. Since the bug has
> existed for many years and is very minor, we consider this
> patch set more suitable for net-next as the major change
> is the refactor itself.
> 
> - v1->v2
>   Fix trivial compile errors

Nice cleanup in patch #2.

Series applied, thanks.
