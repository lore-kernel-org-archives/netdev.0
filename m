From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Fri, 14 Jun 2002 11:09:51 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <aedbpj$qpd$2@main.gmane.org>
References: <5.1.0.14.2.20020612224038.0251bd08@mira-sjcm-3.cisco.com> 	<5.1.0.14.2.20020614100914.01adca48@mira-sjcm-3.cisco.com> <1024069878.20676.1.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lincoln Dale <ltd@cisco.com>, jamal <hadi@cyberus.ca>,
   Horst von Brand <vonbrand@inf.utfsm.cl>,
   "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
List-Id: netdev.vger.kernel.org



Stephen Hemminger wrote:

> It sounds like what you want is socket accounting which works like
> process accounting.  I.e when a socket lifetime ends, put out a record
> with number of packets/bytes sent/received.


Runtime is much more interesting to me.  However, if you are keeping
enough information to do the accounting as you suggest, then it would
be trivial to make it available incrementally over the life of the
socket.

Billing is not the only interesting aspect of this.  It is also good for
any program trying to dynamically tune or understand the lower-level
characteristics of a particular routing path or interface.

Ben




-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
