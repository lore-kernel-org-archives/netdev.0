From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: VLAN patch for 2.4.21
Date: Thu, 7 Aug 2003 09:22:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C9471@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Ben Greear" <greearb@candelatech.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Ben Greear [mailto:greearb@candelatech.com]
> Sent: Wednesday, August 06, 2003 3:27 AM
> To: 'netdev@oss.sgi.com'
> Subject: VLAN patch for 2.4.21
> 
> 
> Here is a patch that adds a few new IOCTL options (not new 
> IOCTLs per se) for the 802.1Q VLANs.
> One ioctl allows one to get the VID for a device by
> the interface name.  A second gets the name of the underlying 
> device for the VLAN device.  Tested on x86 and PPC.
> 
> Comments welcome!
> 
> Thanks,
> Ben
> 

Oh, this is great. You just saved me the work I was going to do
for fixing VLAN stuff over bonding :)
Any idea how to export those in a way that would enable bonding
and alike to include them without getting dependant on 8021q module
being loaded ? (I'm guessing inline function in a .h file, but any
other solution is welcome (coed sample ?).


-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
