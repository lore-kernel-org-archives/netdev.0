From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Tue, 13 Jun 2017 13:25:22 +0200
Message-ID: <20170613112522.GB1877@nanopsycho>
References: <20170612103432.GA1993@nanopsycho>
 <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
 <20170612114345.GB1993@nanopsycho>
 <22f33fa9-1759-57b7-6aea-898f89c9f61f@mojatatu.com>
 <20170612141450.GD1993@nanopsycho>
 <80dd1bc2-80d6-d8fa-6032-d0641ae5d79b@gmail.com>
 <20170612192238.GF1993@nanopsycho>
 <4d150766-dd1e-26f5-43ea-a3c93cdf291b@gmail.com>
 <20170613053258.GA1877@nanopsycho>
 <a7b216d2-921c-c0ac-c036-0466053e807a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33685 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752418AbdFMLZZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:25:25 -0400
Received: by mail-wr0-f196.google.com with SMTP id v104so28923806wrb.0
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 04:25:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <a7b216d2-921c-c0ac-c036-0466053e807a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jun 13, 2017 at 12:53:00PM CEST, jhs@mojatatu.com wrote:
>On 17-06-13 01:32 AM, Jiri Pirko wrote:
>> Mon, Jun 12, 2017 at 09:58:33PM CEST, dsahern@gmail.com wrote:
>> > On 6/12/17 1:22 PM, Jiri Pirko wrote:
>> > > 
>> > > > 3. IMO since these are nla prefixes and new NLA type they should be in
>> > > > uapi/linux/netlink.h
>> > > Including NLA_* type enum? I think it is reasonable.
>> > 
>> > well, maybe not the NLA_BITFIELD. That enum is for policy validation
>> > kernel side so not really part of the API.
>> 
>> Yeah, now I see it. Agreed.
>> 
>
>Jiri, you agreed to a name change? ;-> I want to have some of what
>David A. ate yesterday.

I ok with either of the tree (1 Jamal's, 2 DaveA's) variants.


>
>I agree it is a good idea to have arbitrary size bitmask so we dont
>run out of bit space but we need to restrict the max length possible.
>I dont agree to using the netlink.h as the best location for this
>but lets move on.

Suggest a better place, I don't see one.


>Do you or David A. want to take a crack at this?  I am a little tied
>up.

No time right now. Maybe in July I could allocate some cycles for this.
