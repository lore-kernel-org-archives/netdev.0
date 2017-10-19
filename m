From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp/tcp: fix ireq->opt races
Date: Thu, 19 Oct 2017 13:31:38 +0100 (WEST)
Message-ID: <20171019.133138.1755187507720163652.davem@davemloft.net>
References: <1508269526.31614.113.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49160 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbdJSMbp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:31:45 -0400
In-Reply-To: <1508269526.31614.113.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Oct 2017 12:45:26 -0700

> syzkaller found another bug in DCCP/TCP stacks [1]
> 
> For the reasons explained in commit ce1050089c96 ("tcp/dccp: fix
> ireq->pktopts race"), we need to make sure we do not access
> ireq->opt unless we own the request sock.

This doesn't apply to 'net'.

[davem@kkuri net]$ git am --signoff v2-net-dccp-tcp-fix-ireq--opt-races.patch 
Applying: dccp/tcp: fix ireq->opt races
error: patch failed: include/net/inet_sock.h:96
error: include/net/inet_sock.h: patch does not apply
error: patch failed: net/dccp/ipv4.c:414
error: net/dccp/ipv4.c: patch does not apply
error: patch failed: net/ipv4/inet_connection_sock.c:540
error: net/ipv4/inet_connection_sock.c: patch does not apply
error: patch failed: net/ipv4/syncookies.c:355
error: net/ipv4/syncookies.c: patch does not apply
error: patch failed: net/ipv4/tcp_input.c:6196
error: net/ipv4/tcp_input.c: patch does not apply
error: patch failed: net/ipv4/tcp_ipv4.c:877
error: net/ipv4/tcp_ipv4.c: patch does not apply
