From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: crappy/good gigabit chipsets?
Date: Sat, 27 Nov 2004 12:10:09 +0100
Message-ID: <20041127111009.GB23139@xi.wantstofly.org>
References: <41A81C15.5080905@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Content-Disposition: inline
In-Reply-To: <41A81C15.5080905@gmx.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 27, 2004 at 07:17:57AM +0100, Carl-Daniel Hailfinger wrote:

> Hi,

Hello,


> Which gigabit chipsets do classic data transfer fast enough to
> get a recommendation from the experts?

I'm not much of an expert, but I do have some experience to share.

I tried r8169 (Realtek gigabit chipset, used in various el-cheapo
GigE cards) in a cheap Asus mainboard in a 32/33 slot, and when
throwing enough packets at it the card would just stall with the
driver spewing out various scary-looking PCI errors to the console.
Didn't have time to look into it further at the time (this was on
2.6.9-something.)  Might not be the NIC's fault.

	kernel: r8169: eth1: PCI error (status: 0x8000). Device disabled.
	kernel: r8169: eth1: PCI error (status: 0x8001). Device disabled.
	kernel: r8169: eth1: PCI error (status: 0x8005). Device disabled.
	kernel: r8169: eth1: PCI error (status: 0x8020). Device disabled.

I'm very happy with the e1000 cards.  In the cheap Asus board above,
they don't perform very well, but it would be impossible to make any
NIC perform well in a machine that has its three PCI slots on the
same 32/33 PCI bus as all the other on-board PCI devices.  At least
they've never locked up on me.

On an intel board with independent PCI buses, I see an e1000 'desktop'
NIC filling the pipe for any packet size > ~350 when the card sits on
its own PCI bus.  This is while running at 32/66, CPU being a 2.4GHz
Xeon.


cheers,
Lennert
