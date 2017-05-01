From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] ipv4: get rid of ip_ra_lock
Date: Sun, 30 Apr 2017 22:44:26 -0400 (EDT)
Message-ID: <20170430.224426.1735697418710301007.davem@davemloft.net>
References: <1493399069-31743-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54566 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1946486AbdEACo2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:44:28 -0400
In-Reply-To: <1493399069-31743-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 28 Apr 2017 10:04:29 -0700

> After commit 1215e51edad1 ("ipv4: fix a deadlock in ip_ra_control")
> we always take RTNL lock for ip_ra_control() which is the only place
> we update the list ip_ra_chain, so the ip_ra_lock is no longer needed.
> 
> As Eric points out, BH does not need to disable either, RCU readers
> don't care.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
