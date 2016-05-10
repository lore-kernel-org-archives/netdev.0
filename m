From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net PATCH v2 3/6] net sched: mirred action fix late binding
Date: Tue, 10 May 2016 14:25:44 -0700
Message-ID: <CAM_iQpUn3TtyKGmpR7==JSOb7miKSq5RwjdhSJ=gtjWejooWqw@mail.gmail.com>
References: <1462913371-9699-1-git-send-email-jhs@emojatatu.com> <1462913371-9699-4-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:36118 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbcEJV0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 17:26:05 -0400
Received: by mail-yw0-f194.google.com with SMTP id u62so2256956ywe.3
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 14:26:04 -0700 (PDT)
In-Reply-To: <1462913371-9699-4-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2016 at 1:49 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> The process below was broken and is fixed with this patch.
>
> //add an mirred action and give it an instance id of 1
> sudo tc actions add action mirred egress mirror dev $MDEV  index 1
> //create a filter which binds to mirred action id 1
> sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
> match ip dst 17.0.0.1/32 flowid 1:10 action mirred index 1
>
> Message before bug fix was:
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
