From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 -next] sched: remove NET_XMIT_POLICED
Date: Sat, 11 Jun 2016 17:14:09 -0700
Message-ID: <CAM_iQpWrpHscQUqnaSNZ=q1vhg=+k9zyaYLTRE4QRSxrtvK+iQ@mail.gmail.com>
References: <1465641964-12342-1-git-send-email-fw@strlen.de> <20160611.155407.1424553523659683009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:33725 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbcFLAO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 20:14:29 -0400
Received: by mail-yw0-f177.google.com with SMTP id g20so98504897ywb.0
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2016 17:14:29 -0700 (PDT)
In-Reply-To: <20160611.155407.1424553523659683009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2016 at 3:54 PM, David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sat, 11 Jun 2016 12:46:04 +0200
>
>> sch_atm returns this when TC_ACT_SHOT classification occurs.
>>
>> But all other schedulers that use tc_classify
>> (htb, hfsc, drr, fq_codel ...) return NET_XMIT_SUCCESS | __BYPASS
>> in this case so just do that in atm.
>
> Yes, but it's been like this for two decades.
>
> One of the points of my reply to the previous version of this
> patch is that indeed it is explicitly returned, intentionally.

I think this is a leftover from CONFIG_NET_CLS_POLICE removal.

BTW, probably TC_POLICE_* can be removed together.
