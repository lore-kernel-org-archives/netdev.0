From: Alexander Nyberg <alexn@telia.com>
Subject: Re: 2.6.13-mm1
Date: Sun, 4 Sep 2005 12:26:04 +0200
Message-ID: <20050904102604.GA7026@localhost.localdomain>
References: <20050901035542.1c621af6.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750718AbVIDK0M@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050901035542.1c621af6.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 01, 2005 at 03:55:42AM -0700 Andrew Morton wrote:

> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.13/2.6.13-mm1/
> 

I got:
<7>Dead loop on netdevice eth0, fix it urgently!

When using netconsole and printing out some information from kernel to
console.

The box uses:
netconsole=4444@192.168.1.12/eth0,7002@192.168.1.1/

0000:00:0f.0 Ethernet controller: Linksys NC100 Network Everywhere Fast
Ethernet 10/100 (rev 11)

Relevant config:
CONFIG_NET_TULIP=y
# CONFIG_DE2104X is not set
CONFIG_TULIP=y
CONFIG_TULIP_MWI=y
# CONFIG_TULIP_MMIO is not set
CONFIG_TULIP_NAPI=y


Matt, on another box I got some irq off hangs that went away when removing
netconsole from the .config on a box with 3c59x. Is this known? The
problem is getting backtraces when netconsole is active, but the last
thing I see before the box goes is that some carrier is up...
