From: Ben Greear <greearb@candelatech.com>
Subject: Re: IP stack question
Date: Mon, 24 Jun 2002 12:27:08 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D17728C.5060303@candelatech.com>
References: <Pine.GSO.4.30.0206241450330.13908-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Bloch, Jack" <Jack.Bloch@icn.siemens.com>,
   "'netdev@oss.sgi.com'"
 <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
List-Id: netdev.vger.kernel.org

jamal wrote:
> 
> On Mon, 24 Jun 2002, Ben Greear wrote:

> Try that SO_DONTROUTE and see if solves your problem; you probably have to
> bind the socket to a specific device as well;
> For all that trouble, i would suggest you may just as well write a sock
> packet based  app.

I want to use normal TCP/IP stack as much as possible, so the sock-packet
(or raw) would not work for me, although it would work fine for the original
poster.

I'm also using source-based routing to send out the correct local
interface.  I'll have to look up more information on what SO_DONTROUTE
does, and thanks for the suggestion!

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
