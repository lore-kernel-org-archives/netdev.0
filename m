From: Ben Greear <greearb@candelatech.com>
Subject: Re: SO_BINDTODEVICE mismatch with man page & comments.
Date: Fri, 14 Sep 2007 16:09:38 -0700
Message-ID: <46EB14B2.8010805@candelatech.com>
References: <46EB071B.9070308@candelatech.com>	<20070914.152912.74747426.davem@davemloft.net>	<46EB0D39.4030609@candelatech.com> <20070914.154316.59469764.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:34048 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753713AbXINXJr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:09:47 -0400
In-Reply-To: <20070914.154316.59469764.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Fri, 14 Sep 2007 15:37:45 -0700
> 
>> I will try the patch, but it will probably not be until Monday.
>> The existing code actually can be made to work by passing in
>> a 4+ byte string and setting the first byte to zero, and as
>> far as I can see, that remains the same with the new patch.
> 
> You said the route wasn't cleared correctly in your test, and that's
> one part I'm concerned about making sure is fixed.

> To be honest I'm slightly angry at you.  I can travel for 24 hours
> non-stop on trains and planes and still be mostly responsive to people
> and apply patches.  But I simply ask you to test a simple patch for a
> test case you said you already have and you can't do it until
> Monday?!?!?
> 
> This is why I typically low priority all reports from you, sorry for
> not doing so this time too. :-/

My previous report was because I was trying to get Xorp to work with BINDTODEVICE, and
Xorp's a huge complicated beast.  Due to it's actual use of the socket it would be very
hard to trigger (or notice) the route bug, and since we use a 4-byte null
string instead of depending on the bool value, I think it works around
it anyway.

The reason xorp wasn't working for me when I made the report was a problem
with the netlink headers I was compiling against (didn't support the > 255 routing
tables), but I didn't figure that out until later.  Since the BINDTODEVICE route clearing
code in the kernel appeared to be broken, I thought that might have been the
problem, but in that I was wrong.  I _do_ think the logic was/is wrong, it's just
that I was hitting something else in this particular case.

So, I will have to write a whole new app to test your fix properly, and I
plan to do so, but it will probably be next week.

I appreciate your responsiveness on the patch, as always, and will not be
overly offended if you choose to ignore subsequent reports from me.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

