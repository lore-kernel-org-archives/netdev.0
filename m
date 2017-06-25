From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Remove ndo_dfwd_start_xmit
Date: Sun, 25 Jun 2017 12:18:44 -0400 (EDT)
Message-ID: <20170625.121844.1813144353355058349.davem@davemloft.net>
References: <20170625080912.27999-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
        john.r.fastabend@intel.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751142AbdFYQSt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 12:18:49 -0400
In-Reply-To: <20170625080912.27999-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Sun, 25 Jun 2017 11:09:12 +0300

> Looks like commit f663dd9aaf9e ("net: core: explicitly select a txq before doing l2 forwarding")
> has removed the need for this dedicated xmit function [it even explicitly
> states so in its commit log message] but it hasn't removed the definition
> of the ndo.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Looks good, applied, thanks.
