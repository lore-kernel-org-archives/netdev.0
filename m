From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN patch for 2.4.21
Date: Thu, 07 Aug 2003 00:28:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F31FF8C.9080705@candelatech.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9471@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C9471@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hen, Shmulik wrote:
>>-----Original Message-----
>>From: Ben Greear [mailto:greearb@candelatech.com]
>>Sent: Wednesday, August 06, 2003 3:27 AM
>>To: 'netdev@oss.sgi.com'
>>Subject: VLAN patch for 2.4.21
>>
>>
>>Here is a patch that adds a few new IOCTL options (not new 
>>IOCTLs per se) for the 802.1Q VLANs.
>>One ioctl allows one to get the VID for a device by
>>the interface name.  A second gets the name of the underlying 
>>device for the VLAN device.  Tested on x86 and PPC.
>>
>>Comments welcome!
>>
>>Thanks,
>>Ben
>>
> 
> 
> Oh, this is great. You just saved me the work I was going to do
> for fixing VLAN stuff over bonding :)
> Any idea how to export those in a way that would enable bonding
> and alike to include them without getting dependant on 8021q module
> being loaded ? (I'm guessing inline function in a .h file, but any
> other solution is welcome (coed sample ?).

You can just check the things in the net_device struct directly
I imagine.  The calls I added are mainly to provide the info to
user-space.

What information do you need, and where do you need it?

Also, no word yet from the guys who actually take patches, so dunno
if/when this will get into the tree.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
