From: Ben Greear <greearb@candelatech.com>
Subject: Re: 'iw events' stops receiving events after a while on 4.9 + hacks
Date: Wed, 17 May 2017 08:22:40 -0700
Message-ID: <fa96dfad-8d1b-c48f-df3b-3df0d548a5c6@candelatech.com>
References: <d82d191e-8ede-68c6-c9e0-c381dc874d36@candelatech.com>
 <20170517100844.GC2849@medion.lan>
 <1495027835.2442.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        Bastian Bittorf <bb@npl.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:40532 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbdEQPWm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:22:42 -0400
In-Reply-To: <1495027835.2442.13.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2017 06:30 AM, Johannes Berg wrote:
> On Wed, 2017-05-17 at 12:08 +0200, Bastian Bittorf wrote:
>> * Ben Greear <greearb@candelatech.com> [17.05.2017 11:51]:
>>> I have been keeping an 'iw events' program running with a perl
>>> script gathering its
>>> output and post-processing it.  This has been working for several
>>> years on 4.7 and earlier
>>> kernels, but when testing on 4.9 overnight, I notice that 'iw
>>> events' is not showing any input.  'strace' shows
>>> that it is waiting on recvmsg.  If I start a second 'iw events'
>>> then it will get
>>> wifi events as expected.
>>
>> me too, also seen on 4.4 - i'am happy for debug ideas.
>
> I've never seen this.
>
> Does it happen when it's very long-running? Or when there are lots of
> events?
>
> Perhaps something in the socket buffer accounting is going wrong, so
> that it's slowly decreasing to 0?

I saw it exactly once so far, and it happened overnight,
but we have not been doing a lot of work with the 4.9 kernel until recently.

I don't think there were many messages on this system, and certainly
others have run much longer on systems that should be generating many more
events without trouble.

Is there any way to dump out the socket information if we reproduce
the problem?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
