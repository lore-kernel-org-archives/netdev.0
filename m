From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: Set internal device max mtu to
 ETH_MAX_MTU.
Date: Wed, 15 Feb 2017 12:40:39 -0500 (EST)
Message-ID: <20170215.124039.354499040040426366.davem@davemloft.net>
References: <1487135788-37601-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarod@redhat.com, pshelar@ovn.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752123AbdBORkl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 12:40:41 -0500
In-Reply-To: <1487135788-37601-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Tue, 14 Feb 2017 21:16:28 -0800

> Commit 91572088e3fd ("net: use core MTU range checking in core net
> infra") changed the openvswitch internal device to use the core net
> infra for controlling the MTU range, but failed to actually set the
> max_mtu as described in the commit message, which now defaults to
> ETH_DATA_LEN.
> 
> This patch fixes this by setting max_mtu to ETH_MAX_MTU after
> ether_setup() call.
> 
> Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied, thank you.
