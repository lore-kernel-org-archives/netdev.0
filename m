From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 1/1] net: tcp: Permit user set TCP_MAXSEG to
 default value
Date: Wed, 22 Mar 2017 11:48:13 -0700 (PDT)
Message-ID: <20170322.114813.1044261413851089870.davem@davemloft.net>
References: <1490059683-13884-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42970 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965753AbdCVSsP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:48:15 -0400
In-Reply-To: <1490059683-13884-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Tue, 21 Mar 2017 09:28:03 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> When user_mss is zero, it means use the default value. But the current
> codes don't permit user set TCP_MAXSEG to the default value.
> It would return the -EINVAL when val is zero.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v3: Correct the logic error, per Neal
>  v2: Make codes more clearer, per Eric
>  v1: initial version

Applied to net-next, thanks.
