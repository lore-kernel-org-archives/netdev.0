From: Ben Greear <greearb@candelatech.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
 interfaces
Date: Sun, 11 Jan 2004 14:51:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4001D36B.8070402@candelatech.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com> <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com> <4001C158.6040103@candelatech.com> <4001C72E.8030108@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Noam <amir.noam@intel.com>, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4001C72E.8030108@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Ben Greear wrote:
> 
>> I would also be open to moving the VLAN ioctls over into the
>> ethtool ioctl space, but that just exchanges one magic ioctl for
>> another...
> 
> 
> 
> The key question is what is the best interface for userland to configure 
> in-kernel information -that is unrelated to a specific interface-. 
> ethtool ioctl space doesn't apply, because that's a per-interface API.

Actually, VLANs map very well to a per-interface API, since VLANs are
interfaces and reside on other interfaces.

> Opening a socket and just ioctl'ing away isn't terribly scalable in the 
> long run, either.  Consider all the applications that could legitimately 
> claim they need a SIOCxxx ioctl assignment, just for their little slice 
> of the networking world.  Further, consider that all an ioctl is is a 

My assumption is that adding a new ethtool message (or vlan ioctl message
to the existing VLAN ioctl call) does not cause new emulation problems.
Is that true?

> I'll poke around and see what I can come up with.

I'm interested in seeing the result.  I've never found a simple
example of something using the netlink api, and if it can be done,
then I'll probably convert.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
