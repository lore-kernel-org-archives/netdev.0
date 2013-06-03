From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: RFC - VXLAN port range facility
Date: Mon, 3 Jun 2013 09:21:31 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7261@saturn3.aculab.com>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com><20130530094141.7c125947@nehalam.linuxnetplumber.net><OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com><20130531091338.12fc7df5@nehalam.linuxnetplumber.net><OF19ABC0E6.77100D83-ON85257B7C.005AFB01-85257B7C.005E33DC@us.ibm.com><20130531102233.13e51cff@nehalam.linuxnetplumber.net><OF5DED87DF.8E295C17-ON85257B7C.0061E7B1-85257B7C.0064B099@us.ibm.com> <20130531184310.59c777fb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <netdev-owner@vger.kernel.org>
To: "Stephen Hemminger" <stephen@networkplumber.org>,
	"David Stevens" <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56800 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751100Ab3FCIWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 04:22:20 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06134-03 for <netdev@vger.kernel.org>;
 Mon,  3 Jun 2013 09:22:17 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130531184310.59c777fb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I am wondering if this is just a theoretical problem, or does it occur
> in real life. My simple tests are not causing ICMP to be delivered to
> UDP application (over the VXLAN) but it maybe because of the compare scoring
> in ICMP, or because of use of multicast versus unicast destinations.

Perhaps modify the routing of received ICMP error messages
so that ones referring to the VXLAN destination port get
routed to VXLAN rather than the socket bound to the source
port (this could be made generic).

Some one seems to have invented a protocol that abuses the
normal port number rules.

	David
