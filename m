From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 14:33:42 -0800
Message-ID: <20050331143342.594b70d9.davem@davemloft.net>
References: <424C6089.1080507@candelatech.com>
	<20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>
	<424C6F82.7030609@candelatech.com>
	<20050331135229.432afff3.davem@davemloft.net>
	<20050331140525.04f9a2b1@dxpl.pdx.osdl.net>
	<424C7929.6080200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C7929.6080200@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 14:26:49 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Stephen Hemminger wrote:
> 
> > Other possiblity is adding additional attributes onto the device with sysfs.
> > That is what net/bridge/br_sysfs_if.c does. I'm not claiming it is a pretty
> > kernel programming model, but the user side API is simpler.
> 
> I prefer to stay away from sysfs.  procfs may have it's faults, but at
> least in this case, it is quite straight-forward and easily does what
> I need.  And procfs is less encumbered by flame wars :)

Are you shying away from sysfs merely for encumberance reasons?

You've dissed Jamal's excellent TC action infrastructure, you're
now dissing sysfs as well which can also solve your problems.

All new interfaces are being done through sysfs, that's simply a
fact of life in the kernel.  If you want to buck this trend, you
have to come up with a much better argument than "procfs is more
straight-forward".  Well if sysfs isn't as straightforward, suggest
a layer of interfaces that might make it so.
