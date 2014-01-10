From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 4/4] net_sched: make ingress qdisc lockless
Date: Thu, 9 Jan 2014 16:30:12 -0800
Message-ID: <CAM_iQpUj9kg=15K3yyOWuMEaxWQC2TUStAMjHrn+ixbGyYHK0Q@mail.gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com>
	<1389313313.31367.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33206 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbaAJAaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:30:13 -0500
Received: by mail-ob0-f180.google.com with SMTP id wo20so4085604obc.11
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:30:12 -0800 (PST)
In-Reply-To: <1389313313.31367.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 4:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
> Really, you'll have to explain in the changelog why you think this is
> safe, because I really do not see how this can be valid.
>
> I think I already said it was not safe at all...
>
> You could try a multiqueue NIC for some interesting effects.
>

There is only one ingress queue, that is dev->ingress_queue, right?

And since on ingress, the only possible qdisc is sch_ingress,
looking at ingress_enqueue(), I don't see anything so dangerous.

As I said in the cover letter, I may still miss something in the qdisc
layer, but doesn't look like related with multiqueue. Mind to be more
specific?
