From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: PCI interrupt problem: e1000 & Super-Micro X6DVA motherboard
Date: Thu, 14 Apr 2005 11:01:01 -0700
Message-ID: <5fc59ff305041411013fd35ed4@mail.gmail.com>
References: <42421FF2.7050501@candelatech.com>
	 <20050324081003.GA23453@xi.wantstofly.org>
	 <42431734.3030905@candelatech.com>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261564AbVDNSBG@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <42431734.3030905@candelatech.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben:

Have you checked if the BIOS on the super micro machine is the latest
and greatest. I have had interrupt routing issues very similar to the
one you are describing due to a BIOS Interrupt Routing issue. Moving
to newer BIOS fixed it.

ganesh.

On 3/24/05, Ben Greear <greearb@candelatech.com> wrote:
> Lennert Buytenhek wrote:
> > On Wed, Mar 23, 2005 at 06:03:30PM -0800, Ben Greear wrote:
> >
> >
> >>I have two 4-port e1000 NICs in the system, on a riser card.
> >
> >
> > How is the riser card wired?  F.e. does it have a single edge
> > connector, and provides two PCI slots, or does it have a tiny
> > additional edge connector that routes REQ#/GNT#/INTx from a
> > nearby PCI slot, etc.?
> 
> I was able to reproduce the problem even when the 4-port e1000 NIC
> is plugged directly into the motherboard, so it's not the
> riser...
> 
> I also tried with a 4-port VIA-Rhine NIC (router-board 44).  It also
> fails it's third interface, with the same problem.  So, it is not
> the e1000 NIC nor the e1000 driver that is the problem.
> 
> I do notice that it is the same interrupt (26) that is always assigned
> to the broken port.  I have the lspci and dmesg output for the via-rhine
> boot if anyone wants it...
> 
> Ben
> 
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
>
