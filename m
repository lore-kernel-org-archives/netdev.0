From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next v4 2/3] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Thu, 04 Sep 2014 11:33:49 -0700
Message-ID: <5408B08D.10402@hp.com>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com> <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com> <5408A60A.3070603@hp.com> <5408AFC7.70709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t1525.atlanta.hp.com ([15.193.200.68]:53199 "EHLO
	g6t1525.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032AbaIDSdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 14:33:52 -0400
In-Reply-To: <5408AFC7.70709@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I may not be following the flow correctly, and may be noticing only
>> because I just did two "floor-sweeping" patches to shift be2net and
>> mlx4_en to "consume" but would it be better if these kfree_skb calls
>> were a "consume" variety?
>>
>> rick jones
>
> kfree_skb is probably the correct approach.  In this case it represents
> a buffer that has to be freed due to a Tx timestamp request timeout so
> it would be an event that we would want to trace as an error event.

Thanks.

rick
