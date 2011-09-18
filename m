From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: Very confused about broute DROP
Date: Sat, 17 Sep 2011 20:47:03 -0500
Message-ID: <925A849792280C4E80C5461017A4B8A2A0444C@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com> <20110711130729.607d461e@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com> <20110711134938.5178797c@nehalam.ftrdhcpuser.net> <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com> <20110712000242.GA616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com> <20110712033943.GB616804@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com> <20110712145438.GB909183@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A040FB@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04134@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0413A@mail733.InfraSupportE
 tc.com> <925A849792280C4E80C5461017A4B8A2A04149@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0414B@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A04438@mail733.Infr
	aSupportEtc.
	com> <184D23435BECB444AB6B9D4630C8EC83028548FD@XMB-RCD-303.cisco.com> <925A849792280C4E80C5461017A4B8A2A0443A@mail733.InfraSupportEtc.com> <184D23435BECB444AB6B9D4630C8EC8302854957@XMB-RCD-303.cisco.com> <925A849792280C4E80C5461017A4B8A2A0443B@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Graham Parenteau" <adfgrahame1@gmail.com>
To: "Christian Benvenuti \(benve\)" <benve@cisco.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:25216 "EHLO
	mail.InfraSupportEtc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437Ab1IRBrG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 21:47:06 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A clarification - hopefully my embarrassing mistake can be of some use.
ARP is an L2 protocol, not an L3 protocol.  ARP is  **not** part of IPv4
or IPv6.  Look in the IANA list of IP protocol numbers - there's none
for ARP.  ARP is defined in Layer 2, not L3.  I would have missed that
question on a cert test.  That's why my broute rules need to take ARPs
into account.  

- Greg
