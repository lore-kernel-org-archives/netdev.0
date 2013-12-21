From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on ingress
Date: Fri, 20 Dec 2013 16:24:02 -0800
Message-ID: <CAM_iQpXYpKE6zAAjFjzAW5KN=u7+C1gapz-bvkmVNFsNi+Jqmw@mail.gmail.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com>
	<1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:45523 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657Ab3LUAYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 19:24:02 -0500
Received: by mail-oa0-f52.google.com with SMTP id h16so3658357oag.11
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 16:24:02 -0800 (PST)
In-Reply-To: <1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 4:08 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-12-20 at 15:57 -0800, Cong Wang wrote:
>
>> Just push the lock down to ->enqueue() ? Since ingress qdisc is classless
>> and its ->dequeue() is nop.
>
>
> https://github.com/jrfastab/Linux-Kernel-QOS
>
> https://github.com/jrfastab/Linux-Kernel-QOS/commit/67746f95acd77cf15d7ce34f644b76058ce19813
>

It's a nice idea to introduce a ->prequeue().

And so brave to play with RCU on singly linked list... maybe I can
just steal the ->prequeue() piece. John? :-D

BTW, the last commit is about 5 months ago...
