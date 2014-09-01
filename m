From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Basic deferred TX queue flushing infrastructure.
Date: Mon, 01 Sep 2014 14:40:42 -0700 (PDT)
Message-ID: <20140901.144042.1910318544683468774.davem@davemloft.net>
References: <CAHA+R7O_RSyKVNqcHXePbahvU+ayf77w61jos=G38M93okVWKw@mail.gmail.com>
	<20140825.153146.2165451041039058085.davem@davemloft.net>
	<20140901094032.5f0afdbd@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaIAVkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 17:40:45 -0400
In-Reply-To: <20140901094032.5f0afdbd@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 1 Sep 2014 09:40:32 +0200

> 
> On Mon, 25 Aug 2014 15:31:46 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> 
>> It occurs to me that perhaps the thing to do is to pass sk_buff ** to
>> dev_hard_start_xmit().
> 
> Is this to send an array of skb's to dev_hard_start_xmit()?

It's one possible mechanism.

I have a patch set that rearchitects the send path here which I'll
post in a little bit, which takes a slightly different approach
based upon suggestions by Eric Dumazet and Tom Herbert.
