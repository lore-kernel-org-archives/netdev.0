From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH 00/12] RCU'ify the net:sched classifier chains
Date: Sun, 12 Jan 2014 09:18:06 -0500
Message-ID: <52D2A41E.5050609@mojatatu.com>
References: <20140110092041.7193.5952.stgit@nitbit.x32> <52D2987D.5060807@mojatatu.com> <52D29F4C.90808@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:42050 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaALOSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 09:18:10 -0500
Received: by mail-ig0-f173.google.com with SMTP id ut6so3376111igb.0
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 06:18:09 -0800 (PST)
In-Reply-To: <52D29F4C.90808@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/14 08:57, Jamal Hadi Salim wrote:

> I looked and here's a general question:
> Does even using RCU make any sense here? What we have
> is a lot of updates and very very little reads (reads essentially
> are done from the control side; the data path is is all about updates).
>
> I am not sure if RCU is a win in such a case - it could make things
> worse. At least that used to be the Truth(tm) many moons back.
> Is that not the case anymore?
>

Never mind.
You are not trying to make stats rcu - rather the list
of filters and actions (which is read mostly from data path).
Looking at the u32 piece - i think this is in the right
direction. Good stuff John!

cheers,
jamal
