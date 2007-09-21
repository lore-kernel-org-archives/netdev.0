From: "John Ye" <johny@asimco.com.cn>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run softirq network code on SMP
Date: Fri, 21 Sep 2007 17:25:10 +0800
Message-ID: <00e601c7fc31$4ed29890$ca8510ac@asimco>
References: <002b01c7fb86$02b27df0$d6ddfea9@JOHNYE1> <20070920.104614.58454013.davem@davemloft.net>
Cc: <netdev@vger.kernel.org>, <kuznet@ms2.inr.ac.ru>,
	<pekkas@netcore.fi>, <jmorris@namei.org>, <kaber@coreworks.de>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asimco-na.com ([207.138.153.195]:3063 "EHLO
	mail.asimco-na.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbXIUJXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 05:23:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Thanks for your reply. I understand it's not worth to do.

I have made it a loadable module to fulfill the function. it mainly for busy
NAT gateway server with SMP to speed up.

John Ye



----- Original Message -----
From: "David Miller" <davem@davemloft.net>
To: <johny@asimco.com.cn>
Cc: <netdev@vger.kernel.org>; <kuznet@ms2.inr.ac.ru>; <pekkas@netcore.fi>;
<jmorris@namei.org>; <kaber@coreworks.de>
Sent: Friday, September 21, 2007 1:46 AM
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run softirq
network code on SMP


>
> The whole reason the queues are per-cpu is so that we do not
> have to touch remote processor state nor use locks of any
> kind whatsoever.
>
> With multi-queue networking cards becoming more and more
> available, which will split up the packet workload in
> hardware across all available cpus, there is less and less
> reason to make a patch like this one.
>
> We've known about this issue for ages, and if we felt it
> was appropriate to make this change, we would have done
> so years ago.
>


