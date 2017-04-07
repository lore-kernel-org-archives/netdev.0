From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC 2/3] genetlink: pass extended error report down
Date: Fri, 7 Apr 2017 12:27:33 -0700
Message-ID: <fd15a0bb-535a-ba4f-efbb-fa566e30fcd4@candelatech.com>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
 <20170407182620.6438-3-johannes@sipsolutions.net>
 <25e1fb8c-22e0-d7a2-13a7-d0def5432c9e@candelatech.com>
 <1491592343.5800.8.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:44824 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934112AbdDGT1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 15:27:34 -0400
In-Reply-To: <1491592343.5800.8.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2017 12:12 PM, Johannes Berg wrote:
> On Fri, 2017-04-07 at 11:37 -0700, Ben Greear wrote:
>>
>> I guess the error string must be constant and always available in
>> memory in this implementation?
>
> Yes.
>
>> I think it would be nice to dynamically create strings (malloc,
>> snprintf, etc) and have the err_str logic free it when done?
>
> We can think about that later, but I don't actually think it makes a
> lot of sense - if we point to the attribute and/or offset you really
> ought to have enough info to figure out what's up.

We can think about it later, but lots of things in the wifi stack
could use a descriptive message specific to the failure.  Often these
messages are much more useful if you explain why the failure conflicts
with regulatory, channel, virtual-dev combination, etc info, so that needs
to be dynamic.  The code that is failing knows, so I'd like to pass it
back to user-space.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
