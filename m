From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Fri, 07 Jun 2002 15:15:24 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <adtprm$92q$2@main.gmane.org>
References: <3CFFB9F8.54455B6E@nortelnetworks.com> <20020606.202108.52904668.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cfriesen@nortelnetworks.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

Datagram sockets are the ones that drop data though (tcp will
deal with it via re-transmits).

I have not looked at his patch in detail, but I would welcome anything
that gets us closer to being able to account for every packet that enters
the NIC, or enters the kernel from user-space via send(to), etc...

David S. Miller wrote:

> Your idea is totally useless for non-datagram sockets.
> Only datagram sockets use the interfaces where you bump
> the counters.
> 
> I don't like the patch, nor the idea behind it, at all.
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
