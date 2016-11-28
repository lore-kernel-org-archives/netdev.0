From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] geneve: fix ip_hdr_len reserved for geneve6 tunnel.
Date: Mon, 28 Nov 2016 16:15:07 -0500 (EST)
Message-ID: <20161128.161507.1061361768921587836.davem@davemloft.net>
References: <1480310818-78456-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, aduyck@mirantis.com,
        pshelar@nicira.com, jbenc@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754515AbcK1VPJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:15:09 -0500
In-Reply-To: <1480310818-78456-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Mon, 28 Nov 2016 13:26:58 +0800

> It shold reserved sizeof(ipv6hdr) for geneve in ipv6 tunnel.
> 
> Fixes: c3ef5aa5e5 ('geneve: Merge ipv4 and ipv6 geneve_build_skb()')
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied, thanks.
