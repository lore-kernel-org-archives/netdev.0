From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v6_repost 2/3] net: core: add SW stats to
 if_stats_msg
Date: Tue, 23 Aug 2016 16:52:00 +0200
Message-ID: <20160823145159.GC1975@nanopsycho>
References: <1471612650-4508-3-git-send-email-jiri@resnulli.us>
 <57BBE47D.3060805@cumulusnetworks.com>
 <20160823065318.GA1975@nanopsycho>
 <20160823.000415.624700756560666111.davem@davemloft.net>
 <20160823072651.GB1975@nanopsycho>
 <57BC61CD.9020005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        nogahf@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, ogerlitz@mellanox.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
        eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34934 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbcHWPAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:00:24 -0400
Received: by mail-wm0-f50.google.com with SMTP id f65so166466435wmi.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 07:59:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57BC61CD.9020005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 23, 2016 at 04:46:37PM CEST, roopa@cumulusnetworks.com wrote:
>On 8/23/16, 12:26 AM, Jiri Pirko wrote:
>> Tue, Aug 23, 2016 at 09:04:15AM CEST, davem@davemloft.net wrote:
>>> From: Jiri Pirko <jiri@resnulli.us>
>>> Date: Tue, 23 Aug 2016 08:53:18 +0200
>>>
>>>> Anyway I think that next level of nesting is not necessary. On
>>>> contrary, it is wrong. The current level is extensible, mixed and
>>>> flagged already. I don't see any reason why not to add whatever kind of
>>>> stats here. What makes IFLA_STATS_LINK_SW_64 or for example
>>>> IFLA_STATS_LINK_HW_ACL so special it has to be nested in some other
>>>> attr? I would understand it it would be values of one family, but that
>>>> is not the case.
>>> First, I agree with Roopa.  If we want to put this stuff out
>>> there is should be bucketed together in a nested attribute with
>>> other similar stats specifications.
>> Well I still don't think that IFLA_STATS_LINK_SW_64 and
>> IFLA_STATS_LINK_HW_ACL are related. You cannot put it under *DRIVER*
>> nest as IFLA_STATS_LINK_SW_64 are core stats.
>not sure i understand, why is this core stats ?.
>should a new logical device implement  IFLA_STATS_LINK_64 or IFLA_STATS_LINK_SW_64 ?
>any other users ?.
>
>
>>  So we can put them under
>> *MISC* nest attr. But that is exactly purpose of the top-level here.
>> /me confused
>
>By design top level is for higher level grouping of stats (that also helps us maintain a lean higher
>level filter space). They are mainly categories of stats. for example we have a nested link
>XSTATS attribute..which are again a break down of stats already counted in IFLA_STATS_LINK_64.
>That's why I think we can group this into another kind of breakdown stats.

I give up. What name do you suggest for the nested attribute?

Thanks.
