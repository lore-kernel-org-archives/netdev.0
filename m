From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 12:51:26 -0400 (EDT)
Message-ID: <20140423.125126.244770898759207308.davem@davemloft.net>
References: <1398223137-5463-1-git-send-email-ast@plumgrid.com>
	<20140422.235745.1219194947074686642.davem@davemloft.net>
	<1398229980.29914.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, dborkman@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbaDWQv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 12:51:28 -0400
In-Reply-To: <1398229980.29914.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Apr 2014 22:13:00 -0700

> On Tue, 2014-04-22 at 23:57 -0400, David Miller wrote:
>> From: Alexei Starovoitov <ast@plumgrid.com>
>> Date: Tue, 22 Apr 2014 20:18:57 -0700
>> 
>> > exisiting BPF verifier allows uninitialized access to registers,
>> > 'ret A' is considered to be a valid filter.
>> > So initialize A and X to zero to prevent leaking kernel memory
>> > In the future BPF verifier will be rejecting such filters
>> > 
>> > Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> 
>> Has the code always been like this?
>> 
>> Did the eBPF changes introduce this problem either directly or
>> indirectly?
> 
> Original code was fine AFAIK
> 
> Fixes: bd4cf0ed331a2 ("net: filter: rework/optimize internal BPF interpreter's instruction set")
> 
> David, is it possible for you to push net-next tree ?

What exactly are you asking me to do?  Put this patch in the net-next tree?
Or are you asking me to merge net into net-next after I apply it?

It's definitely a 'net' patch.
