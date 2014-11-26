From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: fq: increase max delay from 125 ms
 to one second
Date: Wed, 26 Nov 2014 12:08:26 -0500 (EST)
Message-ID: <20141126.120826.376208765937261068.davem@davemloft.net>
References: <1416921892-4756-1-git-send-email-yangyingliang@huawei.com>
	<1416933094.29427.27.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416934649.29427.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, netdev@vger.kernel.org,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbaKZRI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:08:27 -0500
In-Reply-To: <1416934649.29427.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Nov 2014 08:57:29 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> FQ/pacing has a clamp of delay of 125 ms, to avoid some possible harm.
> 
> It turns out this delay is too small to allow pacing low rates :
> Some ISP setup very aggressive policers as low as 16kbit.
>     
> Now TCP stack has spurious rtx prevention, it seems safe to increase
> this fixed parameter, without adding a qdisc attribute.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yang Yingliang <yangyingliang@huawei.com>

Applied, thanks Eric.
