From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: [Bonding-devel] [patch] (2/8) Add 802.3ad support to bonding
Date: Thu, 3 Apr 2003 17:42:06 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C92CD@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>, "Marom, Noam" <noam.marom@intel.com>,
   "Feldman, Scott" <scott.feldman@intel.com>
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jay Vosburgh [mailto:fubar@us.ibm.com]
> Sent: Thursday, April 03, 2003 4:01 AM
> To: Hen, Shmulik; Marom, Noam; Feldman, Scott
> Cc: bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
> Subject: RE: [Bonding-devel] [patch] (2/8) Add 802.3ad 
> support to bonding 
> 
> 	If, however, I use "ifenslave -d bond0 ethX" (where ethX is
> one of the active interfaces, by which I mean one with traffic flowing
> over it), it takes a considerable amount of real time for bonding to
> recover and transfer the connection to a new interface.  It appears
> that the deleted interface must be either the transmitting or
> receiving interface (I'm not sure which), as sometimes it recovers
> immediately.  Removing an idle interface from the bond does not appear
> to cause any stalls.
> 

We'll be investigating this behavior and try to reproduce it in our lab
(probably early next week).


	Shmulik.
