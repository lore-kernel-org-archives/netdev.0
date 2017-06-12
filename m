From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Mon, 12 Jun 2017 21:22:38 +0200
Message-ID: <20170612192238.GF1993@nanopsycho>
References: <1497182026-11594-2-git-send-email-jhs@emojatatu.com>
 <20170611134924.GA1896@nanopsycho.orion>
 <4c536950-2be3-cc9c-1f77-066624800d07@mojatatu.com>
 <4441aa62-d00e-82b6-d337-f86cf97e3c6d@mojatatu.com>
 <20170612103432.GA1993@nanopsycho>
 <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
 <20170612114345.GB1993@nanopsycho>
 <22f33fa9-1759-57b7-6aea-898f89c9f61f@mojatatu.com>
 <20170612141450.GD1993@nanopsycho>
 <80dd1bc2-80d6-d8fa-6032-d0641ae5d79b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34563 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752086AbdFLTWl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 15:22:41 -0400
Received: by mail-wr0-f195.google.com with SMTP id u101so24259021wrc.1
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 12:22:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <80dd1bc2-80d6-d8fa-6032-d0641ae5d79b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 12, 2017 at 05:00:41PM CEST, dsahern@gmail.com wrote:
>On 6/12/17 8:14 AM, Jiri Pirko wrote:
>>>> The thing is, struct nla_flag_bits is tightly coupled with NLA_FLAG_BITS
>>>> enum value. They should be in the same uapi file. That makes sense to me.
>>>>
>>>
>>> Sure - they should be in the same file. But is it uapi/linux/netlink.h?
>> 
>> Might be the netlink-types.h you mentioned above.
>> 
>> ccing DavidA.
>> 
>
>Just saw this patch set this morning. Few comments:
>
>1. I think nla_bitfield or nla_bitmap is a better name than nla_flag_bits

ack


>
>2. The length should be open ended with the size of the array determined
>by nla_len / sizeof(struct nla_bitfield). That allows this to be
>extended to an arbitrary large bitfield as needed.

Yeah, I was thinking about that as well. Seems handy to have this
generic len.


>
>3. IMO since these are nla prefixes and new NLA type they should be in
>uapi/linux/netlink.h

Including NLA_* type enum? I think it is reasonable.
