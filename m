From: Ben Greear <greearb@candelatech.com>
Subject: Re: dev->hard_header ?
Date: Tue, 19 Nov 2002 21:06:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DDB1839.4020909@candelatech.com>
References: <005201c2903f$37e88580$21abfe81@seong>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Seong Moon <seong@etri.re.kr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Seong Moon wrote:
> In Layer 3 Protocols(eg. IP, IPv6, ...),
> they calls dev_queue_xmit() to send their data.
> 
> Before calling dev_queue_xmit(),
> does the layer 3 protocols always call dev->hard_header ?
> 
> Actually, I'm not sure when dev->hard_header is called.
> 
> I think dev->hard_start_xmit can include the part of dev->hard_header.
> Why did the developer seperate the header building and sending frame
> fucntion ?

It's not always called, this way user-space (or other parts of the kernel)
can build the headers if desired.  This at least works for ethernet and
VLAN interfaces.

Ben

> 
> thanks in advance.
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
