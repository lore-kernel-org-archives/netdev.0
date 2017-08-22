From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] Simplify the tcp_conn_request.
Date: Tue, 22 Aug 2017 14:16:59 -0700 (PDT)
Message-ID: <20170822.141659.1670288119145470995.davem@davemloft.net>
References: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xiangxia.m.yue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752189AbdHVVRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:17:00 -0400
In-Reply-To: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Date: Mon, 21 Aug 2017 23:33:47 -0700

> Just simplify the tcp_conn_request function.

Series applied, thanks.

The explicit 'dst = NULL' in the variable declaration is probably
superfluous now.

And in fact it was hiding the bug that we didn't have a proper
'dst' early enough.
