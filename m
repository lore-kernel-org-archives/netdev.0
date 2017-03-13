From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: make ECMP route replacement less greedy
Date: Mon, 13 Mar 2017 12:17:49 -0700 (PDT)
Message-ID: <20170313.121749.321517795908552015.davem@davemloft.net>
References: <df56147ddfe635a61f29f651785c02c8c7c56e3d.1489403578.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkubecek@suse.cz,
        nicolas.dichtel@6wind.com, hannes@stressinduktion.org,
        lucien.xin@gmail.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751141AbdCMTRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 15:17:51 -0400
In-Reply-To: <df56147ddfe635a61f29f651785c02c8c7c56e3d.1489403578.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Mon, 13 Mar 2017 13:28:09 +0100

> Commit 27596472473a ("ipv6: fix ECMP route replacement") introduced a
> loop that removes all siblings of an ECMP route that is being
> replaced. However, this loop doesn't stop when it has replaced
> siblings, and keeps removing other routes with a higher metric.
> We also end up triggering the WARN_ON after the loop, because after
> this nsiblings < 0.
> 
> Instead, stop the loop when we have taken care of all routes with the
> same metric as the route being replaced.
 ...
> Fixes: 27596472473a ("ipv6: fix ECMP route replacement")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
