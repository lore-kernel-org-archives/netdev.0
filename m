From: Ben Greear <greearb@candelatech.com>
Subject: Re: PCI interrupt problem: e1000 & Super-Micro X6DVA motherboard
Date: Thu, 24 Mar 2005 00:18:35 -0800
Message-ID: <424277DB.5000504@candelatech.com>
References: <42421FF2.7050501@candelatech.com> <20050324081003.GA23453@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050324081003.GA23453@xi.wantstofly.org>
Sender: linux-kernel-owner@vger.kernel.org
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

It has an edge connector, a full 64-bit ribbon connector, and
a 32-bit ribon connector.  As far as I can tell, there are no
shared signals.

It is made by Adex electronics, and is part number:  P/NPCITX3S1 884-335-185

I tried two different systems, and the problem is identical, so I believe
it is not a hardware manufacturing glitch.  It may be a hardware design
issue in either the riser or the motherboard.  Or a BIOS PCI irq mapping
problem...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
