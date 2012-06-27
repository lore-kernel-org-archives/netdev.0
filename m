From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 01:22:04 -0700 (PDT)
Message-ID: <20120627.012204.1603944185909940692.davem@davemloft.net>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	<1340730156.10893.359.camel@edumazet-glaptop>
	<201206270723.11615.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, subramanian.vijay@gmail.com,
	dave.taht@gmail.com, netdev@vger.kernel.org, ncardwell@google.com,
	therbert@google.com, brouer@redhat.com
To: hans.schillstrom@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab2F0IWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:22:05 -0400
In-Reply-To: <201206270723.11615.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date: Wed, 27 Jun 2012 07:23:03 +0200

> On Tuesday 26 June 2012 19:02:36 Eric Dumazet wrote:
>> With David patch using jhash instead of SHA, I reach ~315.000 SYN per
>> second.
> 
> I have similar results from ~170k to ~199k synack/sec.

Eric and Hans, I'm going to add Tested-by: tags for both of you
when I commit this patch if you don't mind. :-)
