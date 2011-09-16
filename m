From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Very confused about broute DROP
Date: Thu, 15 Sep 2011 22:19:14 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A0443A@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com> <20110712033943.GB616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com> <20110712145438.GB909183@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FB@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04134@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0413A@mail733.InfraSupportE
 tc.com> <925A849792280C4E80C5461017A4B8A2A04149@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0414B@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04438@mail733.Infr
	aSupportEtc.
	com> <184D23435BECB444AB6B9D4630C8EC83028548FD@XMB-RCD-303.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Graham Parenteau" <adfgrahame1@gmail.com>
To: "Christian Benvenuti \(benve\)" <benve@cisco.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:38842 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab1IPDTQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 23:19:16 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If I'm reading the ebtables ARP stuff right, it looks like I can use
this for selective proxy ARPs.  This may have made my life much nicer
with a project that didn't work out very well 5 years ago when I
inherited a network with systems that had public IP Addresses on both
sides of the firewall. For now, why did 

ebtables -t broute -A BROUTING -j DROP

shut my system down and force me to drive over there at 4AM this morning
to undo it?  It's not supposed to really drop, it's supposed to route
it.  And those examples aren't making any sense to me.  

Thanks

- Greg



-----Original Message-----
From: Christian Benvenuti (benve) [mailto:benve@cisco.com] 
Sent: Thursday, September 15, 2011 6:08 PM
To: Greg Scott; netdev@vger.kernel.org
Cc: Graham Parenteau
Subject: RE: Very confused about broute DROP

How about ARP? You need it too ...
