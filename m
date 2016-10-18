From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: ethtool -x full support
Date: Tue, 18 Oct 2016 12:24:15 -0700
Message-ID: <1476818655.5650.69.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476810487.5650.68.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Ariel Elior <ariel.elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34044 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753901AbcJRTYS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 15:24:18 -0400
Received: by mail-pf0-f194.google.com with SMTP id 128so240894pfz.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 12:24:18 -0700 (PDT)
In-Reply-To: <1476810487.5650.68.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-18 at 10:08 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Implement ethtool -x full support, so that rss key can be fetched
> instead of assuming it matches /proc/sys/net/core/netdev_rss_key
> content.

I'll send a V2, tested with CONFIG_BNX2X_SRIOV=y ;)
