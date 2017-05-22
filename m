From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atheros: atl2: don't return zero on failure path
 in atl2_probe()
Date: Mon, 22 May 2017 12:05:17 -0400 (EDT)
Message-ID: <20170522.120517.186219063658821306.davem@davemloft.net>
References: <1495234331-27615-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759419AbdEVQFU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 12:05:20 -0400
In-Reply-To: <1495234331-27615-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 20 May 2017 01:52:11 +0300

> If dma mask checks fail in atl2_probe(), it breaks off initialization,
> deallocates all resources, but returns zero.
> 
> The patch adds proper error code return value and
> make error code setup unified.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Looks good, applied, thanks.
