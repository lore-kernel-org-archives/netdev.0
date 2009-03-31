From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 31 Mar 2009 16:07:34 +0200
Message-ID: <20090331140733.GF6321@e-circ.dyndns.org>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My idea as a user, having configured some servers:

On Tue, Mar 24, 2009 at 05:46:17PM +0200, Matt Domsch wrote:
> 
> Problem:  Users expect on-motherboard NICs to be named eth0..ethN.  This can be difficult to achieve.

with kernel point of view, there should be no preference. If users
expect some numbering, I believe udev provides all the tools.
> 
> Ethernet device names are initially assigned by the kernel, and may be
> changed by udev or nameif in userspace.  The initial name assigned by
> the kernel is in monotonically increasing order, starting with eth0.
> In this instance, the enumeration directly leads to an assigned name.
the problem here is the monotonic increasing order. I never rename ethX
back to the monotonic ethX numbering. IMHO, renaming eth0 to eth1 sounds
redundant.
I rename ethx to lan, wan, wlan, remote, lan0, lan1, ...
This naming _cannot_ conflict.
> 
> 
>       To ease this complication, SMBIOS 2.6 includes a mechanism for
>       BIOS to specify its expected ordering of devices, for naming
>       purposes.  Tools such as biosdevname use this information.
I'd preferrably not rely on bios tools, not every system has a (stable) bios.
> 
> 

