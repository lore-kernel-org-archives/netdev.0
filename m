From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Hang when testing with AMD64 with Tg3
Date: Mon, 04 Oct 2004 17:47:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096937268.22155.11.camel@localhost.localdomain>
References: <1096935071.22155.6.camel@localhost.localdomain>
	 <20041005001527.GB13106@wotan.suse.de>
	 <20041004172948.2023a75e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041004172948.2023a75e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-10-04 at 17:29 -0700, David S. Miller wrote:
> On Tue, 5 Oct 2004 02:15:27 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > I don't see things like this on my boxes with rc3, also with tg3s.
> > 
> > Of what nature is the hang? Does the machine crash?

> And what tg3 revisions do you have?

# ethtool -i eth0
driver: tg3
version: 3.10
firmware-version:
bus-info: 0000:03:02.0

# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off


# lspci -v
0000:03:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5703 Gigabit Ethernet (rev 02)
	Subsystem: IBM: Unknown device 026f
	Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 28
	Memory at c0200000 (64-bit, non-prefetchable)
	Capabilities: [40] PCI-X non-bridge device.
	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
