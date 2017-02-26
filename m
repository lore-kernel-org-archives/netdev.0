From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: add missing initialization for flowi4_uid
Date: Sun, 26 Feb 2017 11:04:43 -0500 (EST)
Message-ID: <20170226.110443.802051019262125409.davem@davemloft.net>
References: <1488117052-20835-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752244AbdBZQXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 11:23:30 -0500
In-Reply-To: <1488117052-20835-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 26 Feb 2017 15:50:52 +0200

> Avoid matching of random stack value for uid when rules
> are looked up on input route or when RP filter is used.
> Problem should affect only setups that use ip rules with
> uid range.
> 
> Fixes: 622ec2c9d524 ("net: core: add UID to flows, rules, and routes")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied and queued up for -stable.
