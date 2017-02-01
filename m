From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix ndo_features_check/ndo_fix_features comment
 ordering
Date: Tue, 31 Jan 2017 16:44:40 -0800
Message-ID: <1485909880.6360.141.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170201000313.11868-1-dmichail@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: Dimitris Michailidis <dmichail@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33569 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdBAAom (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 19:44:42 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so32438357pgd.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 16:44:42 -0800 (PST)
In-Reply-To: <20170201000313.11868-1-dmichail@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-31 at 16:03 -0800, Dimitris Michailidis wrote:
> Commit cdba756f5803a2 ("net: move ndo_features_check() close to
> ndo_start_xmit()") inadvertently moved the doc comment for
> .ndo_fix_features instead of .ndo_features_check. Fix the comment
> ordering.
> 
> Fixes: cdba756f5803a2 ("net: move ndo_features_check() close to ndo_start_xmit()")
> Signed-off-by: Dimitris Michailidis <dmichail@google.com>
> ---


LGTM

Acked-by: Eric Dumazet <edumazet@google.com>

I am currently doing a reorg of net_device fields to improve locality,
I am not sure I will touch comments. We might do this later when things
are stabilized.
