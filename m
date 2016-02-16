From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/8] tc offload for cls_u32 on ixgbe
Date: Tue, 16 Feb 2016 14:50:55 -0500 (EST)
Message-ID: <20160216.145055.1581160555302651949.davem@davemloft.net>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
	<CAJ3xEMhqHbHDH06O5+Y_2mNQM3BNVA9bCLBS70ZK+=-6upDtaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, amir@vadai.me, jhs@mojatatu.com,
	netdev@vger.kernel.org, jiri@resnulli.us,
	jeffrey.t.kirsher@intel.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbcBPTu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 14:50:57 -0500
In-Reply-To: <CAJ3xEMhqHbHDH06O5+Y_2mNQM3BNVA9bCLBS70ZK+=-6upDtaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Tue, 16 Feb 2016 21:30:18 +0200

> On Tue, Feb 16, 2016 at 8:00 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
> [...]
> 
>> Specifically this uses a 'big hammer' feature bit
>> to do the offload or not. If the bit is set you get offloaded rules
>> if it is not then rules will not be offloaded. If we can agree on
>> this patch series there are some more patches on my queue we can
>> talk about to make the offload decision per rule using flags similar
>> to how we do l2 mac updates. Additionally the error strategy can
>> be improved to be hard aborting, log and continue, etc. I think
>> these are nice to have improvements but shouldn't block this series.
> 
> John,
> 
> I thought we've got into agreement in netdev that the offloading
> directive would be a tri-state creature (sw, hw and fail the op if
> can't, hw and fallback to sw). Can you please elaborate what do you
> mean by "make the offload decision per rule using flags similar to how
> we do l2 mac updates"

I think John's changes are an intermediate step in a long term
evoluation.

I'm going to apply John's changes as-is, and people can submit relative
changes on top if they want.
