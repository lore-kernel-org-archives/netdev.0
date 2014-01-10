From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next 1/4] net_sched: switch filter list to list_head
Date: Thu, 9 Jan 2014 16:20:09 -0800
Message-ID: <CAM_iQpXFv5VuFJ9V7Zdc3Nv9PzuH8m5k+3P8HWwyaaHpXxc_Dw@mail.gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389291593-2494-2-git-send-email-xiyou.wangcong@gmail.com>
	<1389313035.31367.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36490 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbaAJAUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:20:11 -0500
Received: by mail-ob0-f172.google.com with SMTP id gq1so4104616obb.31
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:20:10 -0800 (PST)
In-Reply-To: <1389313035.31367.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-01-09 at 10:19 -0800, Cong Wang wrote:
>> So that it could be potentially traversed with RCU.
>
> This never made sense to me.
>
> RCU doesn't need list_head at all.
>
> list_head is convenient (not only for RCU), but not a need.
>

I knew, playing RCU list without using list_head is hard to
get right, at least for me. Maybe I should rephrase it.
