From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net-next PATCH 00/12] net/sched rcu classifiers and tcf
Date: Mon, 15 Sep 2014 10:33:14 +0200
Message-ID: <5416A44A.8040806@redhat.com>
References: <20140913025925.6249.12537.stgit@nitbit.x32> <20140913.123831.1668616111639540979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, xiyou.wangcong@gmail.com,
	eric.dumazet@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752451AbaIOId0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 04:33:26 -0400
In-Reply-To: <20140913.123831.1668616111639540979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2014 06:38 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Fri, 12 Sep 2014 20:04:20 -0700
>
>> This series converts the tcf_proto usage to RCU.
>
> Series applied, thanks John!

Btw, a bit odd that Git shows all commits from 'net: qdisc: use rcu prefix
and silence sparse warnings' up to 'net: sched: rcu'ify cls_bpf' twice in
the log with only one Merge commit of diffstat -0/+0, e.g.:

  https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=9888faefe1327909f3acf34d1feda87a368bb858
  https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c8b9affec519d27ce202a7ed22617eecbd96f127
