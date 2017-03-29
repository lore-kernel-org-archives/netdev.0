From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: hold tunnel socket when handling control
 frames in l2tp_ip and l2tp_ip6
Date: Wed, 29 Mar 2017 09:26:57 -0700 (PDT)
Message-ID: <20170329.092657.563935153265006232.davem@davemloft.net>
References: <3bedc3952e5e1a96f54442b083f935a44d9c3f83.1490769855.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752256AbdC2Q1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 12:27:06 -0400
In-Reply-To: <3bedc3952e5e1a96f54442b083f935a44d9c3f83.1490769855.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 29 Mar 2017 08:44:59 +0200

> The code following l2tp_tunnel_find() expects that a new reference is
> held on sk. Either sk_receive_skb() or the discard_put error path will
> drop a reference from the tunnel's socket.
> 
> This issue exists in both l2tp_ip and l2tp_ip6.
> 
> Fixes: a3c18422a4b4 ("l2tp: hold socket before dropping lock in l2tp_ip{, 6}_recv()")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied.
