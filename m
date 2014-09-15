From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/12] net/sched rcu classifiers and tcf
Date: Mon, 15 Sep 2014 11:43:57 -0400 (EDT)
Message-ID: <20140915.114357.585527565761262206.davem@davemloft.net>
References: <20140913025925.6249.12537.stgit@nitbit.x32>
	<20140913.123831.1668616111639540979.davem@davemloft.net>
	<5416A44A.8040806@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, xiyou.wangcong@gmail.com,
	eric.dumazet@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, brouer@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbaIOPn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 11:43:59 -0400
In-Reply-To: <5416A44A.8040806@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 15 Sep 2014 10:33:14 +0200

> On 09/13/2014 06:38 PM, David Miller wrote:
>> From: John Fastabend <john.fastabend@gmail.com>
>> Date: Fri, 12 Sep 2014 20:04:20 -0700
>>
>>> This series converts the tcf_proto usage to RCU.
>>
>> Series applied, thanks John!
> 
> Btw, a bit odd that Git shows all commits from 'net: qdisc: use rcu
> prefix
> and silence sparse warnings' up to 'net: sched: rcu'ify cls_bpf' twice
> in
> the log with only one Merge commit of diffstat -0/+0, e.g.:
> 
>  https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=9888faefe1327909f3acf34d1feda87a368bb858
>  https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c8b9affec519d27ce202a7ed22617eecbd96f127

That's really amazing :-)

Probably I applied them to my master branch before building the branch and doing
the merge that way, weird.

Sorry about that.
