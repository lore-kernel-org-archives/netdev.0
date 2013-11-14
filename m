From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 v4] Open vSwitch zerocopy upcall
Date: Thu, 14 Nov 2013 02:13:57 -0500 (EST)
Message-ID: <20131114.021357.2293924326693299062.davem@davemloft.net>
References: <cover.1383906944.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab3KNHN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:13:59 -0500
In-Reply-To: <cover.1383906944.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri,  8 Nov 2013 11:47:16 +0100

> Respin of the zerocopy patches for the openvswitch upcall.
> 
> V4: - Daniel Borkmann pointed out that the style in skbuff.h has changed
>       in net-next, adapted to no longer using extern in headers.
> V3: - Removed unneeded alignment of nlmsg_len after padding 
> V2: - Added skb_zerocopy_headlen() to calculate headroom of destination
>       buffer. This also takes care of the from->head_frag issue.
>     - Attribute alignment for frag_list case
>     - API documentation
>     - performance data for CHECKSUM_PARTIAL tx case
> 
> Thomas Graf (2):
>   net: Export skb_zerocopy() to zerocopy from one skb to another
>   openvswitch: Use skb_zerocopy() for upcall

No objections from me for these changes, but it's too late for the
current merge window.

Jesse can feel free to queue this up in his tree and you can add my:

Acked-by: David S. Miller <davem@davemloft.net>

to these patches.

Thanks!
