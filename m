From: Kumar Sanghvi <kumaras@chelsio.com>
Subject: Query regarding sk_filter
Date: Fri, 9 Jan 2015 17:23:04 +0600
Message-ID: <20150109112302.GA9428@kumar-pc.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18709 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754538AbbAILxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 06:53:24 -0500
Received: from nice.asicdesigners.com (nice.asicdesigners.com [10.192.160.7])
	by stargate.chelsio.com (8.13.8/8.13.8) with ESMTP id t09BrOCu002831
	for <netdev@vger.kernel.org>; Fri, 9 Jan 2015 03:53:24 -0800
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev team,

I have a query regarding sk_filter call in tcp receive path:

In 'tcp_v4_rcv' function, if sk is found by __inet_lookup_skb then,
down the line, there is a call to sk_filter to ensure if the incoming packet 
is allowed to be processed for that sk.

However, in 'tcp_v4_hnd_req' function, if nsk is found by inet_lookup_established 
then, later, there does not seem to be a sk_filter call for that nsk in the receive 
path processing.

I am wondering shouldn't there be a sk_filter call on nsk found in 'tcp_v4_hnd_req' 
function ? Or, probably I am missing something.
I am running some high rate syn-flood tests and trying to understand the sk_filter 
behaviour in this case.


Thanks,
Kumar.
