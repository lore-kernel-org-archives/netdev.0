From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [RFC] netlink: fix possible spoofing from non-root
 processes
Date: Wed, 22 Aug 2012 21:53:16 -0700 (PDT)
Message-ID: <20120822.215316.2237073843517796376.davem@davemloft.net>
References: <1345224149-5946-3-git-send-email-pablo@netfilter.org>
	<20120819212327.GA14853@1984>
	<20120820190915.GA3727@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab2HWExR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 00:53:17 -0400
In-Reply-To: <20120820190915.GA3727@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 20 Aug 2012 21:09:15 +0200

> On Sun, Aug 19, 2012 at 11:23:27PM +0200, Pablo Neira Ayuso wrote:
>> On Fri, Aug 17, 2012 at 07:22:29PM +0200, pablo@netfilter.org wrote:
>> [...]
>> > [ I don't know any FOSS program making use of Netlink to communicate
>> >   to processes, please, let me know if I'm missing anyone important ]
>> 
>> Patrick pinged me for little reminder on NETLINK_USERSOCK. We still
>> have to allow netlink-to-netlink userspace communication for it.
>> 
>> So, please find a new version of this patch that allows non-root
>> processes for that Netlink bus. For others, my patch restricts to root
>> processes the ability of sending messages with dst_pid != 0.
> 
> Sorry, I just noticed that you cannot apply this to your net tree
> since it depends on patch 1/2 which is not a fix.
> 
> I'll get back to you with one path that you can apply to your net
> tree.
> 
> I'll resend 1/2 later to net-next once this has been sorted out.

Ok, waiting for new versions of these patches, thanks.
