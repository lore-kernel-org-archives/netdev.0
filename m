From: Phil Karn <karn@ka9q.net>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Mon, 21 Feb 2011 13:47:09 -0800
Message-ID: <4D62DD5D.2040902@ka9q.net>
References: <4D5BADCF.5000804@ka9q.net> <1297874372.30541.29.camel@edumazet-laptop> <AANLkTimrQy6gU8d86m2jM4arMS0rOvEQmn2m-KTE4sx9@mail.gmail.com> <201102211326.00255.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	richard -rw- weinberger <richard.weinberger@gmail.com>,
	kaber@trash.net, netdev@vger.kernel.org
To: Brent Cook <bcook@breakingpoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:65005 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab1BUVrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 16:47:15 -0500
Received: by pvg12 with SMTP id 12so234331pvg.19
        for <netdev@vger.kernel.org>; Mon, 21 Feb 2011 13:47:14 -0800 (PST)
In-Reply-To: <201102211326.00255.bcook@breakingpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/21/11 11:26 AM, Brent Cook wrote:

>> Allowing it but with a big fat warning in logs is even better: "You
>> want your network broken? Sure, can do, but you have been warned."

*By all means* have vconfig issue a warning for 4095 just as it already
does for vlan 1.

As I explained the only reason I wanted to do this was to talk to a
piece of equipment that had been misconfigured to use vlan 4095 so I
could fix it. At the time I was using a newly built Linux system running
off a live CD, and only it had a physical network connection to the
device I was trying to fix.

I'm reminded of the classic example of an airliner that is so "smart"
and "idiot proof" that it always disallows a throttle setting that might
shorten the life of the engines.

The designers hadn't considered the possibility that such a setting
might be necessary to avoid a crash that, too, shortens engine life.

The obvious answer is to allow it but make sure he knows what he's
doing. So it takes noticeably more force to push the handles past the
safe limits, but it can be done if you really want to.

So if an airliner allows a command that might cause costly engine
damage, I think Linux can allow a command that violates a usage
convention written in a spec. With a warning, of course.
