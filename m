From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Sun, 09 Jun 2002 23:08:09 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae1ftc$j0j$2@main.gmane.org>
References: <3D029DAF.5040006@candelatech.com>	<20020608.175108.84748597.davem@redhat.com>	<3D039D22.2010805@candelatech.com> <20020609.213440.04716391.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mark@mark.mielke.cc, cfriesen@nortelnetworks.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org



David S. Miller wrote:

>    From: Ben Greear <greearb@candelatech.com>
>    Date: Sun, 09 Jun 2002 11:23:30 -0700
>    
>    I need to account for packets on a per-session basis, where a
>    session endpoint is a UDP port.  So, knowing global protocol numbers is
>    good, but it is not very useful for the detailed accounting I
>    need.
> 
> Why can't you just disable the other UDP services, and then there is
> no question which UDP server/client is causing the drops.


I run multiple connections at once, so this is not a useful alternative.
My application is fairly unique, though people doing stuff like RTP and
other streaming UDP sessions may be interested in similar counters.


> Every argument I hear is one out of lazyness.  And that is not a


Well, that pretty much finishes this discussion I guess.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
