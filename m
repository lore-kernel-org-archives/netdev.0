From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dccp: fix freeing skb too early for IPV6_RECVPKTINFO
Date: Thu, 16 Feb 2017 10:28:10 -0800
Message-ID: <1487269690.1311.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170216162246.12783-1-andreyknvl@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33516 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932302AbdBPS2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 13:28:12 -0500
Received: by mail-pg0-f66.google.com with SMTP id 5so2619798pgj.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 10:28:12 -0800 (PST)
In-Reply-To: <20170216162246.12783-1-andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-16 at 17:22 +0100, Andrey Konovalov wrote:
> In the current DCCP implementation an skb for a DCCP_PKT_REQUEST packet
> is forcibly freed via __kfree_skb in dccp_rcv_state_process if
> dccp_v6_conn_request successfully returns.
> 
> 			goto discard;

Thanks a lot Andrey !

Acked-by: Eric Dumazet <edumazet@google.com>
