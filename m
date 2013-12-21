From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on
 ingress
Date: Fri, 20 Dec 2013 16:08:49 -0800
Message-ID: <1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:52766 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab3LUAIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 19:08:52 -0500
Received: by mail-yh0-f50.google.com with SMTP id b6so760196yha.37
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 16:08:52 -0800 (PST)
In-Reply-To: <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 15:57 -0800, Cong Wang wrote:

> Just push the lock down to ->enqueue() ? Since ingress qdisc is classless
> and its ->dequeue() is nop.


https://github.com/jrfastab/Linux-Kernel-QOS

https://github.com/jrfastab/Linux-Kernel-QOS/commit/67746f95acd77cf15d7ce34f644b76058ce19813
