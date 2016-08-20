From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] l2tp: Fix the connect status check in
 pppol2tp_getname
Date: Fri, 19 Aug 2016 17:56:15 -0700 (PDT)
Message-ID: <20160819.175615.530629602061548386.davem@davemloft.net>
References: <1471584983-18774-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, g.nault@alphalink.fr,
        philipp@redfish-solutions.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56189 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754781AbcHTA4n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:56:43 -0400
In-Reply-To: <1471584983-18774-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Fri, 19 Aug 2016 13:36:23 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The sk->sk_state is bits flag, so need use bit operation check
> instead of value check.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
