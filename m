From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: reduce severity of PIO buffer alloc
 failures
Date: Wed, 25 Jan 2017 14:44:10 -0500 (EST)
Message-ID: <20170125.144410.136728977042293227.davem@davemloft.net>
References: <4bb401da-f76d-38e8-2368-d36edeb4ac44@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: tpilar@solarflare.com, linux-net-drivers@solarflare.com,
        netdev@vger.kernel.org
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33426 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751925AbdAYToL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:44:11 -0500
In-Reply-To: <4bb401da-f76d-38e8-2368-d36edeb4ac44@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Wed, 25 Jan 2017 13:48:17 +0000

> From: Tomá¹ Pilaø <tpilar@solarflare.com>
> 
> PIO buffer allocation can fail for two valid reasons:
>  - we've run out of them (results in -ENOSPC)
>  - the NIC configuration doesn't support them (results in -EPERM)
> Since both these failures are expected netif_err is excessive.
> 
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied.
