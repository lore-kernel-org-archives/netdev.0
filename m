From: Ben Greear <greearb@candelatech.com>
Subject: Re: PCI interrupt problem: e1000 & Super-Micro X6DVA motherboard
Date: Thu, 24 Mar 2005 11:38:28 -0800
Message-ID: <42431734.3030905@candelatech.com>
References: <42421FF2.7050501@candelatech.com> <20050324081003.GA23453@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050324081003.GA23453@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Wed, Mar 23, 2005 at 06:03:30PM -0800, Ben Greear wrote:
> 
> 
>>I have two 4-port e1000 NICs in the system, on a riser card.
> 
> 
> How is the riser card wired?  F.e. does it have a single edge
> connector, and provides two PCI slots, or does it have a tiny
> additional edge connector that routes REQ#/GNT#/INTx from a
> nearby PCI slot, etc.?

I was able to reproduce the problem even when the 4-port e1000 NIC
is plugged directly into the motherboard, so it's not the
riser...

I also tried with a 4-port VIA-Rhine NIC (router-board 44).  It also
fails it's third interface, with the same problem.  So, it is not
the e1000 NIC nor the e1000 driver that is the problem.

I do notice that it is the same interrupt (26) that is always assigned
to the broken port.  I have the lspci and dmesg output for the via-rhine
boot if anyone wants it...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
