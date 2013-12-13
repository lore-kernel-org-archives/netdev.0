From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3 6/6] net_sched: convert tcf_hashinfo to hlist
 and use rcu
Date: Fri, 13 Dec 2013 13:44:45 -0800
Message-ID: <CAM_iQpXNBdbtcu6gp5oDFLFW3BYHi7NGAC0ztsYGtVViRuM8MA@mail.gmail.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>
	<1386913673-8210-7-git-send-email-xiyou.wangcong@gmail.com>
	<1386917330.19078.141.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:51812 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab3LMVoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:44:46 -0500
Received: by mail-ob0-f180.google.com with SMTP id wo20so2554806obc.39
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:44:45 -0800 (PST)
In-Reply-To: <1386917330.19078.141.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 10:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-12-12 at 21:47 -0800, Cong Wang wrote:
>> So that we don't need to play with singly linked list
>> and of course we can use RCU+spinlock instead of rwlock
>> now.
>
> Just replace the rwlock by spinlock, no need for RCU ?


Good point! It seems this hash list is not on hot path, I think
just spinlock should be enough.
