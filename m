From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next v3 1/6] net_sched: remove get_stats from tc_action_ops
Date: Fri, 13 Dec 2013 10:38:58 -0800
Message-ID: <CAM_iQpXVc7NW2dqkKL211Js_AGERwN2tY=KB-AJsfxcxMqgO0A@mail.gmail.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com>
	<1386913673-8210-2-git-send-email-xiyou.wangcong@gmail.com>
	<52AAF7FD.3090207@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:38697 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab3LMSi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 13:38:59 -0500
Received: by mail-oa0-f51.google.com with SMTP id i7so2522370oag.10
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 10:38:58 -0800 (PST)
In-Reply-To: <52AAF7FD.3090207@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 4:05 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> So where is you 0/6? ;->

It is there, just without any CC. :-)

> General: The spirit of the patches i find agreeable.
> I am against patch 1. Dont just remove ABI/APIs that exist.

I don't think we care about kernel module ABI in upstream,
nor we need to care about any out-of-tree module.
Otherwise they are already broken by any change of sk_buff, right?

> Some of these changes are substantial - did you do any testing?
> If you havent I can help - but at minimal i will ask you do so.
> I will also do more review then with whatever iteration you have around
> sunday. I have other patches i meant to  submit - but i will do them on
> top of yours.
>

Yes, but I just have testcase for u32 filter and basic filter with
mirred action. I don't have time to write testcases for other things
yet.

Thanks!
