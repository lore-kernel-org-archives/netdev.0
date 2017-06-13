From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Tue, 13 Jun 2017 07:32:58 +0200
Message-ID: <20170613053258.GA1877@nanopsycho>
References: <4c536950-2be3-cc9c-1f77-066624800d07@mojatatu.com>
 <4441aa62-d00e-82b6-d337-f86cf97e3c6d@mojatatu.com>
 <20170612103432.GA1993@nanopsycho>
 <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
 <20170612114345.GB1993@nanopsycho>
 <22f33fa9-1759-57b7-6aea-898f89c9f61f@mojatatu.com>
 <20170612141450.GD1993@nanopsycho>
 <80dd1bc2-80d6-d8fa-6032-d0641ae5d79b@gmail.com>
 <20170612192238.GF1993@nanopsycho>
 <4d150766-dd1e-26f5-43ea-a3c93cdf291b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:33601 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751921AbdFMFdC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 01:33:02 -0400
Received: by mail-wr0-f179.google.com with SMTP id v104so121836367wrb.0
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 22:33:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4d150766-dd1e-26f5-43ea-a3c93cdf291b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 12, 2017 at 09:58:33PM CEST, dsahern@gmail.com wrote:
>On 6/12/17 1:22 PM, Jiri Pirko wrote:
>> 
>>> 3. IMO since these are nla prefixes and new NLA type they should be in
>>> uapi/linux/netlink.h
>> Including NLA_* type enum? I think it is reasonable.
>
>well, maybe not the NLA_BITFIELD. That enum is for policy validation
>kernel side so not really part of the API.

Yeah, now I see it. Agreed.
