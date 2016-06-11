From: David Miller <davem@davemloft.net>
Subject: Re: [tipc-discussion] [PATCH] tipc: fix potential null pointer
 dereference in the nla_data function
Date: Sat, 11 Jun 2016 10:32:33 -0700 (PDT)
Message-ID: <20160611.103233.2027314173901979219.davem@davemloft.net>
References: <a692a179-6f59-fdbb-9c49-e943677fce43@gmail.com>
	<20160610.232346.782087200889412685.davem@davemloft.net>
	<CAMXR+-QhKw_Dz+NRcF8PJONEqN997P98dgaSdvdTCKRwj4o1OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net, sploving1@gmail.com,
	jon.maloy@ericsson.com, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: erik.hugne@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbcFKRcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 13:32:36 -0400
In-Reply-To: <CAMXR+-QhKw_Dz+NRcF8PJONEqN997P98dgaSdvdTCKRwj4o1OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@gmail.com>
Date: Sat, 11 Jun 2016 09:46:32 +0200

> On Jun 11, 2016 08:24, "David Miller" <davem@davemloft.net> wrote:
>>
>> From: Baozeng Ding <sploving1@gmail.com>
>> Date: Fri, 10 Jun 2016 10:26:59 +0800
>>
>> > Before calling the nla_data function, make sure the argument is not
> null.
>> > Fix potential null pointer dereference vulnerability for this.
>> >
>> > Signed-off-by: Baozeng Ding <sploving1@gmail.com>
>>
>> TIPC maintainers, please review.
>>
> 
> Nak, nlattrs does not come from userspace in the compat layer, it just
> translates to the legacy TLV thing.
> 
> //E

This reply was done in a manner that the Message-ID got lost,
therefore patchwork cannot associate your reply with the original
patch posting and store it in the conversation attached to the patch.

Please don't do that in the future, thanks.
