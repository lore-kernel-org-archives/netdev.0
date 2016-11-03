From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: dccp: add missing bind_conflict to
 dccp_ipv6_mapped
Date: Thu, 03 Nov 2016 16:51:07 -0400 (EDT)
Message-ID: <20161103.165107.2230811543246914716.davem@davemloft.net>
References: <CAAeHK+y8AEQ7dM6GQa5fezgaQK+arqAfRjyVafq-K0+nqgUvGg@mail.gmail.com>
        <CANn89i+YLvnFZFQTQyUA_jxYtZ1RE1NCCb3F4gqdia+w8wuK8A@mail.gmail.com>
        <1478188786.7065.453.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, netdev@vger.kernel.org,
        syzkaller@googlegroups.com, gerrit@erg.abdn.ac.uk,
        dccp@vger.kernel.org, acme@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756663AbcKCUvJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:51:09 -0400
In-Reply-To: <1478188786.7065.453.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Nov 2016 08:59:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While fuzzing kernel with syzkaller, Andrey reported a nasty crash
> in inet6_bind() caused by DCCP lacking a required method.
> 
> Fixes: ab1e0a13d7029 ("[SOCK] proto: Add hashinfo member to struct proto")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
