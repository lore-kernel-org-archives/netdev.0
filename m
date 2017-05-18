From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: make function udp_skb_dtor_locked static
Date: Thu, 18 May 2017 10:13:18 -0400 (EDT)
Message-ID: <20170518.101318.1804846322170851657.davem@davemloft.net>
References: <20170517085036.15261-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754754AbdERONU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:13:20 -0400
In-Reply-To: <20170517085036.15261-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Wed, 17 May 2017 09:50:36 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Function udp_skb_dtor_locked does not need to be in global scope
> so make it static to fix sparse warning:
> 
> net/ipv4/udp.c: warning: symbol 'udp_skb_dtor_locked' was not
> declared. Should it be static?
> 
> Fixes: 6dfb4367cd911d ("udp: keep the sk_receive_queue held when splicing")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.

Please explcitily say "[PATCH net-next]" in your Subject line next time
so that it is clear what tree your patch is targetting.

Thanks.
