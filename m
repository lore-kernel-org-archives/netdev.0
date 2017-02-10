From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net/sched: Use TC skip flags to reflect
 HW offload status
Date: Fri, 10 Feb 2017 14:36:36 -0500 (EST)
Message-ID: <20170210.143636.253114480501653886.davem@davemloft.net>
References: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jakub.kicinski@netronome.com,
        john.r.fastabend@intel.com, amirva@vadai.me, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46890 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752608AbdBJTgi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 14:36:38 -0500
In-Reply-To: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  9 Feb 2017 16:18:04 +0200

> Currently there is no way of querying whether a filter is
> offloaded to HW or not when using both policy (no flag).
> 
> Reuse the skip flags to show the insertion status by setting
> the skip_hw flag in case the filter wasn't offloaded.
> 
> The bpf patch is compile tested only, Daniel/Jakub, will 
> appreciate your review/ack.
 ...

I'm learning towards suggesting that you use new flags, this way it
will be unambiguous whether we are running an old kernel.

If you just use the skip flag, it's impossible to tell the difference.
