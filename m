From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 14:26:49 -0800
Message-ID: <424C7929.6080200@candelatech.com>
References: <424C6089.1080507@candelatech.com>	<20050331130512.7e4b8bc0@dxpl.pdx.osdl.net>	<424C6F82.7030609@candelatech.com>	<20050331135229.432afff3.davem@davemloft.net> <20050331140525.04f9a2b1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050331140525.04f9a2b1@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> Other possiblity is adding additional attributes onto the device with sysfs.
> That is what net/bridge/br_sysfs_if.c does. I'm not claiming it is a pretty
> kernel programming model, but the user side API is simpler.

I prefer to stay away from sysfs.  procfs may have it's faults, but at
least in this case, it is quite straight-forward and easily does what
I need.  And procfs is less encumbered by flame wars :)

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
