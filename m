From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 01:48:30 -0700 (PDT)
Message-ID: <20120627.014830.1434642663168986540.davem@davemloft.net>
References: <201206270723.11615.hans.schillstrom@ericsson.com>
	<20120627.012204.1603944185909940692.davem@davemloft.net>
	<1340786400.26242.27.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, subramanian.vijay@gmail.com,
	dave.taht@gmail.com, netdev@vger.kernel.org, ncardwell@google.com,
	therbert@google.com, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab2F0Isc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:48:32 -0400
In-Reply-To: <1340786400.26242.27.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Jun 2012 10:40:00 +0200

> On Wed, 2012-06-27 at 01:22 -0700, David Miller wrote:
>> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
>> Date: Wed, 27 Jun 2012 07:23:03 +0200
>> 
>> > On Tuesday 26 June 2012 19:02:36 Eric Dumazet wrote:
>> >> With David patch using jhash instead of SHA, I reach ~315.000 SYN per
>> >> second.
>> > 
>> > I have similar results from ~170k to ~199k synack/sec.
>> 
>> Eric and Hans, I'm going to add Tested-by: tags for both of you
>> when I commit this patch if you don't mind. :-)
> 
> Well, please send your complete patch before (with IPv6 part) ?

Indeed, I'll do that soon, thanks Eric.
