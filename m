From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next 0/4] net: filter: BPF updates
Date: Tue, 19 Mar 2013 15:42:07 +0100
Message-ID: <5148793F.3000000@redhat.com>
References: <cover.1363702456.git.dborkman@redhat.com> <20130319.103803.368214683799955215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jasowang@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755440Ab3CSOmM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 10:42:12 -0400
In-Reply-To: <20130319.103803.368214683799955215.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2013 03:38 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Tue, 19 Mar 2013 15:33:59 +0100
>
>> This set adds i) an ancillary operation to the BPF engine and ii) a
>> BPF JIT image disassembler in order to verify or debug the BPF JIT
>> compilers under arch/*/net/.
>>
>> v1 -> v2:
>> 	- No need to reorder choke_skb_cb structure
>
> So we want the first patch in 'net' right?

Eric and Jason mentioned that they need to do a bug fix, where they
could simplify code for the fix by having the 1st patch of this set
in the net tree as well.

However, all other patches of this set except the last one also depend
on the first one, so it would be net and net-next then. Eric, please
correct me if I'm wrong?
