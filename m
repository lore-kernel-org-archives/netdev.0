From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] net: tcp: Define the TCP_MAX_WSCALE
 instead of literal number 14
Date: Wed, 05 Apr 2017 07:51:53 -0700 (PDT)
Message-ID: <20170405.075153.1383349918282920547.davem@davemloft.net>
References: <1491311388-6393-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        ncardwell@google.com, netdev@vger.kernel.org, fgao@ikuai8.com
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42798 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755326AbdDEOv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 10:51:58 -0400
In-Reply-To: <1491311388-6393-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@foxmail.com
Date: Tue,  4 Apr 2017 21:09:48 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> Define one new macro TCP_MAX_WSCALE instead of literal number '14',
> and use U16_MAX instead of 65535 as the max value of TCP window.
> There is another minor change, use rounddown(space, mss) instead of
> (space / mss) * mss;
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  v2: Correct the literal 14 in comment and log too, per Neal
>  v1: initial version

Applied, thank you.
