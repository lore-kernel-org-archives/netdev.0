From: Ben Greear <greearb@candelatech.com>
Subject: Re: IP stack question
Date: Mon, 24 Jun 2002 10:48:15 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D175B5F.5050403@candelatech.com>
References: <Pine.GSO.4.30.0206240922230.12806-100000@shell.cyberus.ca>
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
> I tried to explain to you in private mail:
> Both 10.1.1.4 and 10.1.1.5 are recognized to be local addresses
> by the IP stack. It is legit that the stack limits the scope
> to just that i.e _local_
>  The only way to do what you want to do is bypass the IP stack.
> Use packet socket to write your  test app.
> (which actually probably defetas the whole purpose of what you may
> be trying to do -- HA).

It would not defeat the purpose of detecting at least one bad network
link of the two.

I wonder if a ping -I eth1 255.255.255.255 would accomplish the
goal as well?

I would actually like to be able to force a machine to not do local
routing as well, and force packets out over an interface even if
the destination is a local IP,  using source-based-routing,
or something similar.  There is no way to do this currently?

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
