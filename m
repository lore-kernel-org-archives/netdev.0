From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlabel: out of bound access in
 cipso_v4_validate()
Date: Sat, 04 Feb 2017 19:45:12 -0500 (EST)
Message-ID: <20170204.194512.872874146522400400.davem@davemloft.net>
References: <1486109006.21871.79.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul@paul-moore.com, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751231AbdBEApR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 19:45:17 -0500
In-Reply-To: <1486109006.21871.79.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Feb 2017 00:03:26 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller found another out of bound access in ip_options_compile(),
> or more exactly in cipso_v4_validate()
> 
> Fixes: 20e2a8648596 ("cipso: handle CIPSO options correctly when NetLabel is disabled")
> Fixes: 446fda4f2682 ("[NetLabel]: CIPSOv4 engine")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov  <dvyukov@google.com>

Applied and queued up for -stable.
