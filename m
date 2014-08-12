From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net-timestamp: fix missing tcp fragmentation cases
Date: Tue, 12 Aug 2014 15:16:35 -0700 (PDT)
Message-ID: <20140812.151635.1278569430365375157.davem@davemloft.net>
References: <CA+FuTSeSCPyr7Rb7v+Wzx9c7VY+kFgUwJsNh-=NzcJW-u8W24w@mail.gmail.com>
	<1407870492-20193-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755441AbaHLWQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:16:35 -0400
In-Reply-To: <1407870492-20193-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 12 Aug 2014 15:08:12 -0400

> Bytestream timestamps are correlated with a single byte in the skbuff,
> recorded in skb_shinfo(skb)->tskey. When fragmenting skbuffs, ensure
> that the tskey is set for the fragment in which the tskey falls
> (seqno <= tskey < end_seqno).
> 
> The original implementation did not address fragmentation in
> tcp_fragment or tso_fragment. Add code to inspect the sequence numbers
> and move both tskey and the relevant tx_flags if necessary.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Also applied, thanks Willem.
