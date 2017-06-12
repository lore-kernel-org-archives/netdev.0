From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Mon, 12 Jun 2017 09:00:41 -0600
Message-ID: <80dd1bc2-80d6-d8fa-6032-d0641ae5d79b@gmail.com>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-2-git-send-email-jhs@emojatatu.com>
 <20170611134924.GA1896@nanopsycho.orion>
 <4c536950-2be3-cc9c-1f77-066624800d07@mojatatu.com>
 <4441aa62-d00e-82b6-d337-f86cf97e3c6d@mojatatu.com>
 <20170612103432.GA1993@nanopsycho>
 <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
 <20170612114345.GB1993@nanopsycho>
 <22f33fa9-1759-57b7-6aea-898f89c9f61f@mojatatu.com>
 <20170612141450.GD1993@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33805 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752086AbdFLPAp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 11:00:45 -0400
Received: by mail-pf0-f193.google.com with SMTP id d5so4444086pfe.1
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 08:00:45 -0700 (PDT)
In-Reply-To: <20170612141450.GD1993@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/12/17 8:14 AM, Jiri Pirko wrote:
>>> The thing is, struct nla_flag_bits is tightly coupled with NLA_FLAG_BITS
>>> enum value. They should be in the same uapi file. That makes sense to me.
>>>
>>
>> Sure - they should be in the same file. But is it uapi/linux/netlink.h?
> 
> Might be the netlink-types.h you mentioned above.
> 
> ccing DavidA.
> 

Just saw this patch set this morning. Few comments:

1. I think nla_bitfield or nla_bitmap is a better name than nla_flag_bits

2. The length should be open ended with the size of the array determined
by nla_len / sizeof(struct nla_bitfield). That allows this to be
extended to an arbitrary large bitfield as needed.

3. IMO since these are nla prefixes and new NLA type they should be in
uapi/linux/netlink.h
