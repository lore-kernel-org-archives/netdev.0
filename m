From: Ben Greear <greearb@candelatech.com>
Subject: Re: IP stack question (how to force pkts to not route locally, but
 go out interfaces regardless of destination)
Date: Tue, 27 Aug 2002 23:25:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D6C6CF6.9040002@candelatech.com>
References: <Pine.GSO.4.30.0206241450330.13908-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: "Bloch, Jack" <Jack.Bloch@icn.siemens.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jamal wrote:
> Ben Wrote:
>>I would actually like to be able to force a machine to not do local
>>routing as well, and force packets out over an interface even if
>>the destination is a local IP,  using source-based-routing,
>>or something similar.  There is no way to do this currently?
>>
> 
> 
> Try that SO_DONTROUTE and see if solves your problem; you probably have to
> bind the socket to a specific device as well;
> For all that trouble, i would suggest you may just as well write a sock
> packet based  app.

I am back to trying to figure out how to make this work.  I'm tried source
based routing, and it does not work (it routes internally).

I read the help on SO_DONTROUTE, but it seems to make the kernel not able
to send to a router.  I would like to be able to route, ie port a -> router -> port b

I already bind to a particular port and IP, and use policy based routing
(source based routing) to make sure the packet is sent out the correct
local interface.

I just need to find the routing logic that notices the destination IP is local
and tell it to quit looking (probably for a particular socket, as I can
see how this could break applications who didn't expect it)

I dug through the code once before looking for this, and didn't find
what I needed.  Can anyone suggest the right files and/or methods to
look in?

Thanks,
Ben

> 
> cheers,
> jamal
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
