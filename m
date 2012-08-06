From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] igb: use build_skb()
Date: Mon, 06 Aug 2012 14:28:50 -0700
Message-ID: <50203712.1040404@intel.com>
References: <1343922692.9299.231.camel@edumazet-glaptop>  <50200066.6060905@intel.com> <1344277315.26674.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25883 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753658Ab2HFV2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 17:28:49 -0400
In-Reply-To: <1344277315.26674.54.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2012 11:21 AM, Eric Dumazet wrote:
> On Mon, 2012-08-06 at 10:35 -0700, Alexander Duyck wrote:
>
>> I was planning to move igb over to an ixgbe style receive path at some
>> point anyway.  Since it seems like this is now a higher priority I
>> figured I would try to get the patches for it implemented in the next
>> week or so.  Would there be any issue with us rejecting this patch and
>> instead switching igb over to the ixgbe style path?
> It seems I missed this part.
>
> I use igb on my dev machine, not on prod machines, so if you are moving
> igb to ixgbe, I can certainly can maintain my patch in my tree, while
> you make your changes.
>
I'll try to get the coding for this finished up this week and I can
probably send you a copy of the patches as an RFC.  We will do testing
and hopefully we can have the patches pushed to net-next for 3.7.

Thanks,

Alex
