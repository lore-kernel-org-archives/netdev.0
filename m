From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: RE: Very confused about broute DROP
Date: Thu, 15 Sep 2011 23:23:20 -0500
Message-ID: <184D23435BECB444AB6B9D4630C8EC8302854957@XMB-RCD-303.cisco.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com> <20110712033943.GB616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com> <20110712145438.GB909183@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FB@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04134@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0413A@mail733.InfraSupportE
 tc.com> <925A849792280C4E80C5461017A4B8A2A04149@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0414B@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04438@mail733.Infr
	aSupportEtc.
	com> <184D23435BECB444AB6B9D4630C8EC83028548FD@XMB-RCD-303.cisco.com> <925A849792280C4E80C5461017A4B8A2A0443A@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Graham Parenteau" <adfgrahame1@gmail.com>
To: "Greg Scott" <GregScott@Infrasupport.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:23940 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826Ab1IPEcs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 00:32:48 -0400
Content-class: urn:content-classes:message
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A0443A@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What I meant is that your host needs to be able to route
(which means ... to process) its own ARP traffic, ... IPv4
does not work without ARP, right?
This means you need to add one more DROP rule for the ARP
traffic that is addressed to the MAC of the host interfaces
(nothing to do with proxy ARP).

/Chris

> -----Original Message-----
> From: Greg Scott [mailto:GregScott@Infrasupport.com]
> Sent: Thursday, September 15, 2011 8:19 PM
> To: Christian Benvenuti (benve); netdev@vger.kernel.org
> Cc: Graham Parenteau
> Subject: RE: Very confused about broute DROP
> 
> If I'm reading the ebtables ARP stuff right, it looks like I can use
> this for selective proxy ARPs.  This may have made my life much nicer
> with a project that didn't work out very well 5 years ago when I
> inherited a network with systems that had public IP Addresses on both
> sides of the firewall. For now, why did
> 
> ebtables -t broute -A BROUTING -j DROP
> 
> shut my system down and force me to drive over there at 4AM this
> morning
> to undo it?  It's not supposed to really drop, it's supposed to route
> it.  And those examples aren't making any sense to me.
> 
> Thanks
> 
> - Greg
> 
> 
> 
> -----Original Message-----
> From: Christian Benvenuti (benve) [mailto:benve@cisco.com]
> Sent: Thursday, September 15, 2011 6:08 PM
> To: Greg Scott; netdev@vger.kernel.org
> Cc: Graham Parenteau
> Subject: RE: Very confused about broute DROP
> 
> How about ARP? You need it too ...
> 
