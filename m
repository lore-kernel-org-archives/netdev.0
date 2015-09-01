From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] flow_dissector: Paramterize dissection
 and other features
Date: Tue, 01 Sep 2015 15:22:22 -0700 (PDT)
Message-ID: <20150901.152222.2028025215885843736.davem@davemloft.net>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbbIAWWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 18:22:23 -0400
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 1 Sep 2015 09:24:22 -0700

> This patch set adds some new capabilities to flow_dissector:
> 
> - Add flags to flow dissector functions to control dissection
>   - Flag to stop dissection when L3 header is seen (don't
>     dissect L4)
>   - Flag to stop dissection when encapsulation is detected
>   - Flag to parse first fragment of fragmented packet. This
>     may provide L4 ports
> - Added new reporting in key_control
>   - Packet is a fragment
>   - Packet is a first fragment
>   - Packet has encapsulation
> 
> Also:
>   - Make __skb_set_sw_hash a general function
>   - Create functions to get a flow hash based on flowi4 or flowi6
>     structures without an reference to an skbuff
>   - Ignore flow dissector return value from ___skb_get_hash. Just
>     use whatever key fields are found to make a hash
> 
> Tested:
 ...

This looks fine, series applied, thanks Tom.
