From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: VLAN patch for 2.4.21
Date: Thu, 7 Aug 2003 13:22:05 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C9472@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Ben Greear" <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Ben Greear [mailto:greearb@candelatech.com]
> Sent: Thursday, August 07, 2003 10:28 AM
> To: Hen, Shmulik
> Cc: netdev@oss.sgi.com
> Subject: Re: VLAN patch for 2.4.21
> 
> 
> You can just check the things in the net_device struct directly
> I imagine.  The calls I added are mainly to provide the info to
> user-space.

That was my guess too. I'll figure out a way to do that
safely from kernel space.

> What information do you need, and where do you need it?

In bonding, to better handle self generated packets, I'll need
to know what vlan ID's are on top of the bond device. So, I'll
need to listen to net dev registration notifications and sort
out which ones are for VLAN devices, and then see if they were
added on top of a bond device. Once I've got that, I'll need to
get the VID and store it in bonding, so both your additions
do exactly what I need. I also heard from the bridge developers
that they wanted similar support, so that's 2 birds...


	Shmulik.
