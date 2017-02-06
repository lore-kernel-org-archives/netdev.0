From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: don't rearm interrupts if busy polling
Date: Mon, 06 Feb 2017 11:59:47 -0500 (EST)
Message-ID: <20170206.115947.1451263729529424407.davem@davemloft.net>
References: <ccee0048-9399-3d13-8274-790833b992d9@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
        edumazet@google.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBFQ7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:59:49 -0500
In-Reply-To: <ccee0048-9399-3d13-8274-790833b992d9@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Mon, 6 Feb 2017 16:50:55 +0000

> Since commit 364b6055738b ("net: busy-poll: return busypolling status
> to drivers"), napi_complete_done() returns a boolean that can be used
> by drivers to conditionally rearm interrupts.
> 
> Testing with a 7142 shows a small latency improvement of ~100 ns.
> 
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied.
