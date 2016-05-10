From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net PATCH v2 1/6] net sched: vlan action fix late binding
Date: Tue, 10 May 2016 14:22:45 -0700
Message-ID: <CAM_iQpUS3dRY1cGtt_+G97=WoYc9a8Liz0T=F1c9KotAwdC__A@mail.gmail.com>
References: <1462913371-9699-1-git-send-email-jhs@emojatatu.com> <1462913371-9699-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36355 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbcEJVXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 17:23:06 -0400
Received: by mail-yw0-f193.google.com with SMTP id u62so2250596ywe.3
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 14:23:05 -0700 (PDT)
In-Reply-To: <1462913371-9699-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 10, 2016 at 1:49 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Late vlan action binding was broken and is fixed with this patch.
>
> //add a vlan action to pop and give it an instance id of 1
> sudo tc actions add action vlan pop index 1
> //create filter which binds to vlan action id 1
> sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32 \
> match ip dst 17.0.0.1/32 flowid 1:1 action vlan index 1
>
> current message(before bug fix) was:
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
