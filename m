From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] uapi: export nf_log.h
Date: Sat, 03 Dec 2016 19:23:46 -0500 (EST)
Message-ID: <20161203.192346.1198940437155108508.davem@davemloft.net>
References: <20161202225400.32751-1-sthemmin@microsoft.com>
        <20161202225400.32751-4-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, jhs@mojatatu.com,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39526 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbcLDAYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 19:24:20 -0500
In-Reply-To: <20161202225400.32751-4-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri,  2 Dec 2016 14:54:00 -0800

> File is in uapi directory but not being copied on
>  make install_headers
> 
> Fixes commit 4ec9c8fbbc22 ("netfilter: nft_log: complete
> NFTA_LOG_FLAGS attr support").
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Also applied.

Someone has to explain to me why we don't simply export every single
file under uapi/, it makes no sense to me to have to specify them
explicitly.

We obviously forget to add the files to the lists all the time.
