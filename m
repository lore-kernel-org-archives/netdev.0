From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Wed, 26 Aug 2015 10:32:03 -0700
Message-ID: <55DDF813.4030101@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com> <20150825.171248.291365392844717283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32859 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbbHZRea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 13:34:30 -0400
Received: by pacti10 with SMTP id ti10so94745255pac.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 10:34:29 -0700 (PDT)
In-Reply-To: <20150825.171248.291365392844717283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/08/15 17:12, David Miller wrote:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Tue, 25 Aug 2015 15:50:10 -0700
> 
>> This patch series implements a L2 only interface concept which
>> basically denies any kind of IP address configuration on these
>> interfaces, but still allows them to be used as configuration
>> end-points to keep using ethtool and friends.
>>
>> A cleaner approach might be to finally come up with the concept of
>> net_port which a net_device would be a superset of, but this still
>> raises tons of questions as to whether we should be modifying
>> userland tools to be able to configure/query these
>> interfaces. During all the switch talks/discussions last year, it
>> seemed to me like th L2-only interface is closest we have to a
>> "network port".
>>
>> Comments, flames, flying tomatoes welcome!
> 
> Interesting, indeed.
> 
> Do you plan to extend this to defining a more minimal network device
> sub-type as well?
> 
> Then we can pass "net_device_common" or whatever around as a common
> base type of actual net device "implementations".

I am a little worried this is not going to scale well without
introducing massive amounts of churn, but I am not opposed to the idea
of having a common denominator structure which is either further
specialized into a full-fledged net_device, or some other construct.

> 
> Or is you main goal just getting the L2-only semantic?

Yes, this was the main goal behind this submission, and see if there was
something obviously wrong with doing that.

Now, based on the feedback, it seems like there is both interest and
uses cases I had not initially thought about, like making this flag
fully volatile.

Thanks!
-- 
Florian
