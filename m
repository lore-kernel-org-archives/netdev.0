From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCN v2 net-next] net_sched: gen_estimator: complete rewrite
 of rate estimators
Date: Sun, 04 Dec 2016 09:10:54 -0800
Message-ID: <1480871454.18162.463.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480835273.18162.457.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480835882.18162.462.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33321 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLDRK4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 12:10:56 -0500
In-Reply-To: <1480835882.18162.462.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-12-03 at 23:18 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> 1) Old code was hard to maintain, due to complex lock chains.
>    (We probably will be able to remove some kfree_rcu() in callers)
> 
> 2) Using a single timer to update all estimators does not scale.
> 
> 3) Code was buggy on 32bit kernel (WRITE_ONCE() on 64bit quantity
>    is not supposed to work well)

A v3 is under way, fixing a last "make htmldocs" warning.
