From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: reinstate rtnl in
 call_netdevice_notifiers()
Date: Thu, 23 Aug 2012 09:24:52 -0700 (PDT)
Message-ID: <20120823.092452.436642005687255049.davem@davemloft.net>
References: <1345708259.5904.178.camel@edumazet-glaptop>
	<87harum39o.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gaofeng@cn.fujitsu.com,
	netdev@vger.kernel.org, therbert@google.com, maheshb@google.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab2HWQYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 12:24:54 -0400
In-Reply-To: <87harum39o.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 23 Aug 2012 01:16:51 -0700

> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Eric Biederman pointed out that not holding RTNL while calling
>> call_netdevice_notifiers() was racy.
>>
>> This patch is a direct transcription his feedback
>> against commit 0115e8e30d6fc (net: remove delay at device dismantle)
>>
>> Thanks Eric !
> 
> Looks good to me.
> 
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks.
