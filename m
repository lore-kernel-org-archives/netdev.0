From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: [Bonding][patch] Adding Transmit load balancing mode to bondi
	ng
Date: Tue, 1 Apr 2003 19:09:09 +0300
Sender: linux-net-owner@vger.kernel.org
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C92C4@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: bonding-devel@lists.sourceforge.net,
	bonding-announce@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
content-class: urn:content-classes:message
List-Id: netdev.vger.kernel.org

We haven't experimented with layer 4 load balancing in the past. I guess
this is because of the big overhead of parsing the skb for the necessary
data, but also because of the risk of dealing with IP fragmentation, large
send issues, encryption and all kinds of off-loadings.


	Shmulik.

> -----Original Message-----
> From: David S. Miller [mailto:davem@redhat.com]
> Sent: Thursday, March 27, 2003 6:06 PM
> To: Hen, Shmulik
> Cc: bonding-devel@lists.sourceforge.net; 
> bonding-announce@lists.sourceforge.net; 
> linux-net@vger.kernel.org; netdev@oss.sgi.com; 
> linux-kernel@vger.kernel.org; jgarzik@pobox.com
> Subject: Re: [Bonding][patch] Adding Transmit load balancing 
> mode to bonding
> 
> 
>    From: shmulik.hen@intel.com
>    Date: Thu, 27 Mar 2003 17:38:02 +0200 (IST)
> 
>    Balancing is connection oriented (e.g. by IPv4 destination address)
>    so packet order is always kept.
> 
> You could also key off of the destination/source port as well for
> UDP/TCP/SCTP.  Have you experimented with this?
> 
