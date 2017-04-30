From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH/RFC net-next 0/4] net/sched: cls_flower: avoid false
 matching of truncated packets
Date: Sun, 30 Apr 2017 10:45:34 -0400
Message-ID: <80417d97-4c47-c77b-9c8c-9e2487250a76@mojatatu.com>
References: <20170428120035.15984-1-simon.horman@netronome.com>
 <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
 <20170428131155.GA30329@vergenet.net>
 <2c14754a-f3f5-cece-2cd7-361948a00c22@mojatatu.com>
 <20170428141414.GA11256@vergenet.net>
 <0e993860-4dfd-3562-5ccb-c5ad24e5f970@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36597 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754484AbdD3Oph (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 10:45:37 -0400
Received: by mail-it0-f45.google.com with SMTP id r185so17496244itd.1
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 07:45:37 -0700 (PDT)
In-Reply-To: <0e993860-4dfd-3562-5ccb-c5ad24e5f970@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-30 09:51 AM, Jamal Hadi Salim wrote:

[..]

>> 1. As things stand, without this patch-set, flower does not differentiate
>>    between a packet truncated at the end of the IP header and a packet
>> with
>>    zero ports. Likewise for icmp type and code of zero.
>>
>>    The first three patches of this series address that so that a match
>> for
>>    port == zero only matches if ports are present in the packet. Again,
>>    likewise for ICMP.
>>
>>    This is a bug-fix to my way of thinking.
>>
>
> Agreed to bug fix. I would have said there is never a legit packet with
> TCP/UDP

Meant:
"never a legit packet with TCP/UDP port 0 on the wire".

cheers,
jamal
