From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: reload iphdr in ipip6_rcv
Date: Sun, 04 Jun 2017 23:05:36 -0400 (EDT)
Message-ID: <20170604.230536.1620448034333617753.davem@davemloft.net>
References: <1496558623-11437-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751230AbdFEDFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 23:05:40 -0400
In-Reply-To: <1496558623-11437-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sun,  4 Jun 2017 14:43:43 +0800

> Since iptunnel_pull_header() can call pskb_may_pull(),
> we must reload any pointer that was related to skb->head.
> 
> Fixes: a09a4c8dd1ec ("tunnels: Remove encapsulation offloads on decap")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied and queued up for -stable, thank you.
