From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Wed, 18 Jan 2017 06:06:59 -0500
Message-ID: <b38b0ec1-9671-22e3-96e1-8612cf44287f@mojatatu.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <20170108171251.GF1971@nanopsycho>
 <040c6876-a323-0a35-229f-46bc33b6de11@mellanox.com>
 <587BC894.3080909@gmail.com>
 <11bcf09a-0144-fd7f-369b-771962475c5e@mellanox.com>
 <20170116095129.GB1804@nanopsycho.orion>
 <59ac74c5-5301-a958-74dd-c5fee669a94b@mojatatu.com>
 <6be8f641-16ad-88a4-d7c3-474dc3b10e71@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Paul Blakey <paulb@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:32795 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754275AbdARLHI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 06:07:08 -0500
Received: by mail-qk0-f196.google.com with SMTP id 11so1276132qkl.0
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 03:07:08 -0800 (PST)
In-Reply-To: <6be8f641-16ad-88a4-d7c3-474dc3b10e71@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-17 06:53 AM, Paul Blakey wrote:
>
>

>>
>> Should be "trivial" like my patch.
>> Add a new TLV type in TCA_XXX enum in rtnetlink.h
>> in  tc_ctl_tfilter look for it and memcpy it
>> in tcf_fill_node set it on the new TCA_XXX if the cls struct
>> has it present.
>>
>
> That's exactly what I did before I realized it won't work per internal
> element (per handle), which is what I want. see my example.
>
> So I'll probably implement it like actions dumping/init works -
> tcf_exts_init, tcf_exts_dump (calling a generic functions on all
> classifiers who want this).
> I'll add something like get_cookie, dump_cookie. which get/set the
> TCA_COOKIE.
>

Yes, that makes more sense.

cheers,
jamal
