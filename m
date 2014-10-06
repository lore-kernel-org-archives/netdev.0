From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 net-next 2/2] bonding: Simplify the xmit function
 for modes that use xmit_hash
Date: Mon, 06 Oct 2014 17:13:43 -0400 (EDT)
Message-ID: <20141006.171343.562229383265827215.davem@davemloft.net>
References: <1412469901-27451-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
	nikolay@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	maze@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbaJFVNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:13:46 -0400
In-Reply-To: <1412469901-27451-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sat,  4 Oct 2014 17:45:01 -0700

> Earlier change to use usable slave array for TLB mode had an additional
> performance advantage. So extending the same logic to all other modes
> that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
> Also consolidating this with the earlier TLB change.
> 
> The main idea is to build the usable slaves array in the control path
> and use that array for slave selection during xmit operation.
> 
> Measured performance in a setup with a bond of 4x1G NICs with 200
> instances of netperf for the modes involved (3ad, xor, tlb)
> cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
> 
> Mode        TPS-Before   TPS-After
> 
> 802.3ad   : 468,694      493,101
> TLB (lb=0): 392,583      392,965
> XOR       : 475,696      484,517
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied.
