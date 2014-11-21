From: Tom Herbert <therbert@google.com>
Subject: Re: Translation table available between 'ethtool -k' and 'ethtool -K'
 ? For Linux?
Date: Thu, 20 Nov 2014 20:36:16 -0800
Message-ID: <CA+mtBx_m8kZck4Lr8wj6G-R7pREiB6Fut1Xf=q6eB3x2u3hh_Q@mail.gmail.com>
References: <BABF60987D48764FA4071AC73CB9C56162EBFBD0AC@AUSX7MCPC101.AMER.DELL.COM>
	<1416526354.7215.4.camel@decadent.org.uk>
	<CA+mtBx9SJ5mhLBMk8E0gGceweMyzJ2icBfjGJc0rjOTDVQZi1Q@mail.gmail.com>
	<20141120.230507.1288958595564653550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>, Spike_White@dell.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:63602 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757162AbaKUEgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 23:36:17 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so4083434igd.7
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 20:36:16 -0800 (PST)
In-Reply-To: <20141120.230507.1288958595564653550.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Thu, 20 Nov 2014 17:07:44 -0800
>
>> Ben I'm not sure I see this. If we turn off HW offloads and rely on
>> the software offloads where is the increased risk? This may result in
>> performance degradation for sure, but I really hope at this point that
>> the software offload mechanisms in the stack are as least as robust as
>> any HW mechanism.
>
> It means you're testing a configuration different from %99 of users
> (who are not changing the defaults).  You are by definition testing
> code paths with less overall global testing coverage.

Remarkably, this is the second time this week I've heard of a user
unilaterally turning off LRO/TSO in their network because of perceived
issues. I wonder if this is happening more often then we might hope...
