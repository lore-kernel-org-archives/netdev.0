From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nf-next 1/1] net: tcp: Refine the __tcp_select_window
Date: Thu, 30 Mar 2017 15:42:10 -0700 (PDT)
Message-ID: <20170330.154210.2218850010642353664.davem@davemloft.net>
References: <1490827759-12142-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, netdev@vger.kernel.org,
        fgao@ikuai8.com
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36132 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932381AbdC3WmM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 18:42:12 -0400
In-Reply-To: <1490827759-12142-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@foxmail.com
Date: Thu, 30 Mar 2017 06:49:19 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> 1. Move the "window = tp->rcv_wnd;" into the condition block without
> tp->rx_opt.rcv_wscale.
> Because it is unnecessary when enable wscale;
> 
> 2. Use the macro ALIGN instead of two statements.
> The two statements are used to make window align to 1<<wscale.
> Use the ALIGN is more clearer.
> 
> 3. Use the rounddown to make codes clearer.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied, but please do not target non-netfilter patches using
"nf-next" in your Subject lines.
