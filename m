From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI:  dev.c change to net_rx_action algorithm.
Date: Fri, 08 Nov 2002 20:55:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DCC9535.3050506@candelatech.com>
References: <Pine.GSO.4.30.0211082326220.16986-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> The only thing i can think of is that if it was legal to flog people
> youd be on my list. And i would hope you dont enjoy it.
> Why do you like to put band-aids to things?
> Find the real cause of why you may be having problems then cure it;
> putting arbitrary hacks just because you can is rather against
> the basic principles of engineering.
> 
> cheers,
> jamal

I'm looking for the real cause.  The current code does not work
as I want it to.  So, I'm changing things.  I would love to try
out any patch you might feel like contributing.

 From what I can tell, the old code punishes interfaces who are
running slower at any given time.  My change, I believe, will
allow slower interfaces to gather a bit more quota so that when
they are hit with a burst of traffic, they can spend a little
extra time to clear their buffers.

I would also welcome any argument as to why my code is worse
than the existing code.  And theoretical papers be damned,
I see better results with the change below.  Why is that?

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
