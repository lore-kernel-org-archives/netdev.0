From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Tue, 17 Jan 2017 06:23:49 -0500
Message-ID: <59ac74c5-5301-a958-74dd-c5fee669a94b@mojatatu.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <20170108171251.GF1971@nanopsycho>
 <040c6876-a323-0a35-229f-46bc33b6de11@mellanox.com>
 <587BC894.3080909@gmail.com>
 <11bcf09a-0144-fd7f-369b-771962475c5e@mellanox.com>
 <20170116095129.GB1804@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>, Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33926 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751118AbdAQLdK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 06:33:10 -0500
Received: by mail-yw0-f195.google.com with SMTP id v73so1505084ywg.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 03:33:09 -0800 (PST)
In-Reply-To: <20170116095129.GB1804@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-16 04:51 AM, Jiri Pirko wrote:
> Mon, Jan 16, 2017 at 08:54:18AM CET, paulb@mellanox.com wrote:
>>
>>

>
> I think we should do it in a generic way, for every classifier, right
> away. Same as Jamal is doing for actions. I think that first we should
> get Jamal's patch merged and then do the same for classifiers.
>

Should be "trivial" like my patch.
Add a new TLV type in TCA_XXX enum in rtnetlink.h
in  tc_ctl_tfilter look for it and memcpy it
in tcf_fill_node set it on the new TCA_XXX if the cls struct
has it present.

Look at my patch (1 of 2) which I just reposted.

cheers,
jamal
