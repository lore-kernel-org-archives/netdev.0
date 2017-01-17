From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: ping: Use right format specifier to
 avoid type casting
Date: Tue, 17 Jan 2017 15:26:22 -0500 (EST)
Message-ID: <20170117.152622.1655518798156744976.davem@davemloft.net>
References: <1484619679-17728-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750863AbdAQU03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 15:26:29 -0500
In-Reply-To: <1484619679-17728-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Tue, 17 Jan 2017 10:21:19 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The inet_num is u16, so use %hu instead of casting it to int. And
> the sk_bound_dev_if is int actually, so it needn't cast to int.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
