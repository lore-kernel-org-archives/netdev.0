From: Timothy Miller <miller@techsource.com>
Subject: Re: TOE brain dump
Date: Tue, 05 Aug 2003 15:28:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F300549.60800@techsource.com>
References: <20030803194011.GA8324@work.bitmover.com> <Pine.LNX.4.44.0308031253240.24695-100000@dlang.diginsite.com> <20030803203051.GA9057@work.bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Lang <david.lang@digitalinsight.com>,
   Erik Andersen
 <andersen@codepoet.org>,
   Werner Almesberger <werner@almesberger.net>,
   Jeff
 Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org, Nivedita Singhvi <niv@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Larry McVoy <lm@bitmover.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Larry McVoy wrote:
> On Sun, Aug 03, 2003 at 01:13:24PM -0700, David Lang wrote:
> 
>>2. router nodes that have access to main memory (PCI card running linux
>>acting as a router/firewall/VPN to offload the main CPU's)
> 
> 
> I can get an entire machine, memory, disk, > Ghz CPU, case, power supply,
> cdrom, floppy, onboard enet extra net card for routing, for $250 or less,
> quantity 1, shipped to my door.
> 
> Why would I want to spend money on some silly offload card when I can get 
> the whole PC for less than the card?


Physical space?  Power usage?  Heat dissipation?  Optimization for the 
specific task?  Fast, low latency communication between CPU and device 
(ie. local bus)?  Maintenance?

Lots of reasons why one might pay more for the offload card.  If you're 
cheap, you'll just use the software stack and a $10 NIC and just live 
with the corresponding CPU usage.  If you're a performance freak, you'll 
spend whatever you have to to squeeze out every last bit of performance 
you can.

Mind you, another option is, if you're dealing with the kind of load 
that requires that much network performance, is to use redundant 
servers, like google.  No one server is exceptionally fast, but it not 
many people are using it, it's fast enough.
