From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: Intel 1000 MT slow to restart
Date: Wed, 2 Apr 2003 15:53:52 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C92C6@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>,
   "Patrick R. McManus"
	 <mcmanus@ducksong.com>, netdev@oss.sgi.com
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Feldman, Scott 
> Sent: Wednesday, April 02, 2003 7:19 AM
> To: Patrick R. McManus; netdev@oss.sgi.com
> Subject: RE: Intel 1000 MT slow to restart
> 
> 
> > I'm running intel's e1000 driver (versions 4.4.12 and tried 
> > 4.6.11) for a 1000/MT (dual) nic on a 2.4.19 kernel.
> > 
> > for normal operations, everything is fine.. however if I do a 
> > "ifconfig eth0 down; ifconfig eth0 up" 20 or 30 seconds 
> > passes where I can't do any traffic. the ifconfig up comes 
> > back quickly, and ifconfig reports the driver as up (and 
> > netlink thinks its up if I try and add another one).. I just 
> > can't move any traffic. no rx's and my tx's only move 
> > counters in the driver - they don't actually make it to the wire. 
> > 
> > if I do "ifconfig eth0 down; sleep 30; ifconfig eth0 up" all 
> > is well immediately after the up.. The driver doesn't seem to 
> > be doing anything different in either case - its as if the 
> > NIC itself is enforcing some kind of quiet period. 
> > 
> > I'm really writing to see if I'm crazy and hoping someone 
> > else can corroborate this is what they've seen too.
> 
> Do you have spanning tree turned on on your switch?  This could cause
> such delays.
> 
> -scott
> 

We've also seen this behavior with certain switches (e.g. Extreme Networks
Summit 7i) even with STP turned off.
The switch simply delays traffic for ~30sec after link was restored. I
believe this delay is configurable.

	Shmulik.
