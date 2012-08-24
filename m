From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-tcp: fix cwnd reduction for non-sack recovery
Date: Fri, 24 Aug 2012 13:49:51 -0400 (EDT)
Message-ID: <20120824.134951.1258077615464850610.davem@davemloft.net>
References: <1345741517-30504-1-git-send-email-ycheng@google.com>
	<CAB_+Fg6QhPDPo7o-QUMuOkkAuLWXPZwUoH2uG4q=jmph9Yv9ng@mail.gmail.com>
	<CADVnQykjK=7cL9pu1EqU+HyiVX_ujSbJ-T1Ohb+M41w4rm1wuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, ycheng@google.com, mattmathis@google.com,
	netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761Ab2HXRty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:49:54 -0400
In-Reply-To: <CADVnQykjK=7cL9pu1EqU+HyiVX_ujSbJ-T1Ohb+M41w4rm1wuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 23 Aug 2012 13:25:50 -0400

> On Thu, Aug 23, 2012 at 1:21 PM, Nandita Dukkipati <nanditad@google.com> wrote:
>> On Thu, Aug 23, 2012 at 10:05 AM, Yuchung Cheng <ycheng@google.com> wrote:
>>> The cwnd reduction in fast recovery is based on the number of packets
>>> newly delivered per ACK. For non-sack connections every DUPACK
>>> signifies a packet has been delivered, but the sender mistakenly
>>> skips counting them for cwnd reduction.
>>>
>>> The fix is to compute newly_acked_sacked after DUPACKs are accounted
>>> in sacked_out for non-sack connections.
>>>
>>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
 ...
>> Acked-by: Nandita Dukkipati <nanditad@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied, and queued up for -stable, thanks.

Please use plain "tcp: " as the prefix for pure tcp changes.  Thanks.
