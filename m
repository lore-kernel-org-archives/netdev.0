From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 03 Dec 2013 13:55:14 -0800
Message-ID: <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	 <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	 <20131203.165034.1085515763685633822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, joseph.gasparakis@intel.com,
	hkchu@google.com, ogerlitz@mellanox.com, edumazet@google.com,
	ast@plumgrid.com, pshelar@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:53862 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755106Ab3LCVzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 16:55:19 -0500
Received: by mail-yh0-f41.google.com with SMTP id f11so10683205yha.14
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 13:55:19 -0800 (PST)
In-Reply-To: <20131203.165034.1085515763685633822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-03 at 16:50 -0500, David Miller wrote:

> At this point I would use drop monitor to figure out in what context
> packets are being dropped on the floor.  There are scripts provided
> with the perf tool to utilize it.

Most easy way is to do :

perf record -e skb:kfree_skb -a -g sleep 10

perf report
