From: jamal <hadi@cyberus.ca>
Subject: RE: [SET 2][PATCH 2/8][bonding] Propagating master's settings to
	slaves
Date: 10 Aug 2003 22:51:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060570284.1056.15.camel@jzny.localdomain>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2003-08-09 at 06:29, Hen, Shmulik wrote:

> > 
> 
> Not sure I fully understood the concerns above, but I'll try
> to explain what the change was all about.
> 

I think it wasnt the one specific change rather a few posted that i
spent a minute or two staring at. And you confirm my suspicion below.

[..]

> 
> In the lonf term, the drive is to move any *smart* code done in
> the config application into the driver itself and be left with
> the smallest, most compact application as possible. This is the
> trend we've seen in the VLAN config app, and the bridge module.
> All the "brain" is in the kernel module and very little should be
> done in the application.

I am not very familiar with the bonding code although i think you guys
have been doing very good work since you got involved.
In any case the approach you state above is wrong. Actually Stephen
Hemminger and I discussed this for bridging. Post 2.6 he is going to
remove a lot of the bridge policy (or "brain" as you call it) out of the
kernel. Netlink for kernel<->userspace not /proc. I think we should head
towards that direction so we can have more sophisticated management.

Thoughts?

cheers,
jamal
