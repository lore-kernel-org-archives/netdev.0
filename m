From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: avoid two atomic ops per page on x86
Date: Mon, 23 Jan 2017 11:18:03 -0500 (EST)
Message-ID: <20170123.111803.192246884167319287.davem@davemloft.net>
References: <1484929534.16328.134.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krisman@linux.vnet.ibm.com,
        Yuval.Mintz@cavium.com, ariel.elior@cavium.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdAWQSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:18:09 -0500
In-Reply-To: <1484929534.16328.134.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jan 2017 08:25:34 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 4cace675d687 ("bnx2x: Alloc 4k fragment for each rx ring buffer
> element") added extra put_page() and get_page() calls on arches where
> PAGE_SIZE=4K like x86
> 
> Reorder things to avoid this overhead. 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
> Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
> Cc: Ariel Elior <ariel.elior@cavium.com>

Applied, thanks.
