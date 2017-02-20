From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Set event bit after initializing
 labels.
Date: Mon, 20 Feb 2017 10:19:08 -0500 (EST)
Message-ID: <20170220.101908.2063172674505500313.davem@davemloft.net>
References: <1487383918-17894-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753298AbdBTPTK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:19:10 -0500
In-Reply-To: <1487383918-17894-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Fri, 17 Feb 2017 18:11:58 -0800

> Connlabels are included in conntrack netlink event messages only if
> the IPCT_LABEL bit is set in the event cache (see
> ctnetlink_conntrack_event()).  Set it after initializing labels for a
> new connection.
> 
> Found upon further system testing, where it was noticed that labels
> were missing from the conntrack events.
> 
> Fixes: 193e30967897 ("openvswitch: Do not trigger events for unconfirmed connections.")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied.
