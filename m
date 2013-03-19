From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] net: filter: BPF updates
Date: Tue, 19 Mar 2013 10:51:11 -0400 (EDT)
Message-ID: <20130319.105111.544492969414189008.davem@davemloft.net>
References: <cover.1363702456.git.dborkman@redhat.com>
	<20130319.103803.368214683799955215.davem@davemloft.net>
	<5148793F.3000000@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jasowang@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab3CSOvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:51:13 -0400
In-Reply-To: <5148793F.3000000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 19 Mar 2013 15:42:07 +0100

> On 03/19/2013 03:38 PM, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Tue, 19 Mar 2013 15:33:59 +0100
>>
>>> This set adds i) an ancillary operation to the BPF engine and ii) a
>>> BPF JIT image disassembler in order to verify or debug the BPF JIT
>>> compilers under arch/*/net/.
>>>
>>> v1 -> v2:
>>> 	- No need to reorder choke_skb_cb structure
>>
>> So we want the first patch in 'net' right?
> 
> Eric and Jason mentioned that they need to do a bug fix, where they
> could simplify code for the fix by having the 1st patch of this set
> in the net tree as well.
> 
> However, all other patches of this set except the last one also depend
> on the first one, so it would be net and net-next then. Eric, please
> correct me if I'm wrong?

That's fine, I can handle such dependencies without any problems.
