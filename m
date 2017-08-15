From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH net] openvswitch: fix skb_panic due to the incorrect
 actions attrlen
Date: Tue, 15 Aug 2017 14:02:55 +0800
Message-ID: <CAML_gOfew0w7Zhna2+2XeLMh6qV73bYNkOnV_cZ07+OCbrD_jA@mail.gmail.com>
References: <20170813070420.73074-1-zlpnobody@163.com> <CAOrHB_Cy-bxRABSR4keg43U7tj4riVAdFd8So1GUHkNzYXA7bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Liping Zhang <zlpnobody@163.com>,
        Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Neil McKee <neil.mckee@inmon.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35243 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdHOGC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 02:02:57 -0400
Received: by mail-pg0-f65.google.com with SMTP id l64so105188pge.2
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 23:02:56 -0700 (PDT)
In-Reply-To: <CAOrHB_Cy-bxRABSR4keg43U7tj4riVAdFd8So1GUHkNzYXA7bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-08-15 13:01 GMT+08:00 Pravin Shelar <pshelar@ovn.org>:
[...]
>>  net/openvswitch/actions.c  | 39 +++++++++++++++++++++++++--------------
>>  net/openvswitch/datapath.c |  2 +-
>>  net/openvswitch/datapath.h |  1 +
>>  3 files changed, 27 insertions(+), 15 deletions(-)
>>
>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> index e4610676299b..799a22dfb89e 100644
>> --- a/net/openvswitch/actions.c
>> +++ b/net/openvswitch/actions.c
>> @@ -48,6 +48,7 @@ struct deferred_action {
>>         struct sk_buff *skb;
>>         const struct nlattr *actions;
>>         int actions_len;
>> +       int actions_attrlen;
>>
> Have you considered passing this value using struct ovs_skb_cb? That
> would save passing this parameter in all these functions.

Thanks for your reviewing.

Right, this will make codes more clean, I will send V2 later.
