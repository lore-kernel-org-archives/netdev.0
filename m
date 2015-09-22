From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] openvswitch: Zero flows on allocation.
Date: Mon, 21 Sep 2015 18:11:34 -0700
Message-ID: <CAEP_g=9j-JwN6Ufc23jczaP4kGYoLi-5fL_pmqi1BAeV=N_heg@mail.gmail.com>
References: <1442628374-57025-1-git-send-email-jesse@nicira.com> <20150920.232400.1768865193135146379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:36862 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754284AbbIVBLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 21:11:55 -0400
Received: by lanb10 with SMTP id b10so78506176lan.3
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 18:11:54 -0700 (PDT)
In-Reply-To: <20150920.232400.1768865193135146379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 20, 2015 at 11:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Fri, 18 Sep 2015 19:06:14 -0700
>
>> @@ -80,7 +80,7 @@ struct sw_flow *ovs_flow_alloc(void)
>>       struct flow_stats *stats;
>>       int node;
>>
>> -     flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
>> +     flow = kmem_cache_alloc(flow_cache, GFP_KERNEL | __GFP_ZERO);
>>       if (!flow)
>
> Like Eric, I prefer that you use kmem_cache_zalloc() to fix
> this.

Sure, I'll make both changes and send out a new patch in a bit.
