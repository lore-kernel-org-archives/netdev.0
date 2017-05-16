From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 10/10] net: sched: add termination action to
 allow goto chain
Date: Tue, 16 May 2017 08:46:26 -0400
Message-ID: <6118ec19-9093-eaf2-6677-28c128e636a9@mojatatu.com>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170515083857.3615-11-jiri@resnulli.us> <591A0940.2070801@iogearbox.net>
 <20170516044319.GA24493@nanopsycho> <591AB168.30202@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36514 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdEPMq3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 08:46:29 -0400
Received: by mail-it0-f68.google.com with SMTP id z15so13283721ite.3
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 05:46:29 -0700 (PDT)
In-Reply-To: <591AB168.30202@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-16 03:59 AM, Daniel Borkmann wrote:
> On 05/16/2017 06:43 AM, Jiri Pirko wrote:
>> Mon, May 15, 2017 at 10:02:08PM CEST, daniel@iogearbox.net wrote:

[..]
>>>
>>> Given this goto chain feature is pretty much only interesting for hw
>>> offloads, can we move this further away from the sw fast path to not
>>> add up to the cost per packet? (I doubt anyone is using
>>> TC_ACT_RECLASSIFY
>>> in sw as well ...)
>>
>> I don't think so. First of all, the whole thing would be broken then in
>> sw. It is useful to have it in sw, at least for testing reasons.
>> So I would leave the unlikely and add it to the second check as well.
>
> Ok, lets go with that then, thanks!

Side comment:
I dont think this is only useful for h/w offloads;->

cheers,
jamal
