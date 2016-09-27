From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 4/7] ipv6 addrconf: add new sysctl
 'router_solicitation_max_interval'
Date: Tue, 27 Sep 2016 11:49:47 +0200
Message-ID: <8e332a23-5653-1e70-7c74-e7bcbbe0884a@stressinduktion.org>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com>
 <1474801390-6891-5-git-send-email-zenczykowski@gmail.com>
 <87d7f248-4d95-4253-78ae-6dd110db6330@stressinduktion.org>
 <CANP3RGfNGgw9H5Hsn7sgadHu5+kBcGfhY6Y_iTKNEjoL9gL7xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:57876 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932222AbcI0Jtt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 05:49:49 -0400
In-Reply-To: <CANP3RGfNGgw9H5Hsn7sgadHu5+kBcGfhY6Y_iTKNEjoL9gL7xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.09.2016 04:30, Maciej Żenczykowski wrote:
>> Is seconds granular enough?
> 
> The only reason why one would ever want to go into fractions of
> seconds would be some sort of unittesting with very low delays.
> 
> In any normal environment the max is going to be tens if not hundreds
> or thousands of seconds.
> 
> Also note that the delay and interval (ie. not max interval) are also
> currently exported in seconds, so having more granularity for
> max_seconds is kind of pointless.
> 
> I have been considering whether I could make proc_dointvec_jiffies
> accept floating point input (and output) though... although that seems
> a little harder and probably out of scope of this change.

Good point. Using ms should actually be easy, instead of
proc_dointvec_jiffies you can use proc_dointvec_ms_jiffies.

It seems good practice to add a _ms then to the sysctl, too.

I am fine with both ways.

Bye,
Hannes
