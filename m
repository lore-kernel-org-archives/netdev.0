From: jamal <hadi@cyberus.ca>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
	interfaces
Date: 11 Jan 2004 17:50:29 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1073861429.1119.312.camel@jzny.localdomain>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com>
	 <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com>
	 <4001C158.6040103@candelatech.com>  <4001C72E.8030108@pobox.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, Amir Noam <amir.noam@intel.com>,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4001C72E.8030108@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-01-11 at 16:59, Jeff Garzik wrote:
> ioctls are a pain for 32/64-bit emulation layers too.  It seems much 
> easier to define a netlink protocol family of some sort and communicate 
> that way.
> 
> I'll poke around and see what I can come up with.

Theres a L2C netlink protocol (for Layer2 Config) which is already in
place being reviewed by DaveM in whatever spurious time he has.
Current user is MPLS but definete candidate for VLAN, and the move of
bridging STP control to user space. It is true that netlink may not be
intuitive to use for someone who hasnt spent time eyeballing it(mostly
because of lack of programming docs really). We are going to try and
improve things by making it easy to use from both kernel and user space
POV and provide sample code which people can cutnpaste in the classical
linux-way(tm). 

cheers,
jamal
