From: "Jon Fraser" <J_Fraser@bit-net.com>
Subject: intel 82543 gig-e and vlans
Date: Thu, 24 Oct 2002 17:12:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001801c27ba2$086684d0$3701020a@CONCORDIA>
Reply-To: <J_Fraser@bit-net.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "Netdev List \(E-mail\)" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello,

	I tried turning on vlan support for an intel 82543 based
gig-e card. This is under linux 2.4.20-pre11. The card is connected
to an ixia test box. I captured some arps and Ixia claims the
header is a CISCO ISL header instead of getting an 802.1q header.
I've copied the header below.  I've tried to break it up by fields.

	CISCO ISL header
01 00 0C 00 00 00		Dst address	
00 03 47 9B 67 CB		Src Address
00 3A				Len
AA AA 03 			Magic number?
00 03 47 
01 90 			Vlan ID	(200)
00 00 00 00

Ethernet header
FF FF FF FF FF FF 00 03 47 9B 67 CB 08 06 
Arp Header
00 01 08 00 06 04 00 01
00 03 47 9B 67 CB 		Sender Address
C8 01 02 01 			Sender IP 200.1.2.1
00 00 00 00 00 00		Target Address
C8 01 02 02			Target IP 200.1.2.2

Has anybody else seen anything like this?

I tried the same test on an intel eep100 with vlans enabled
and everything looks fine.  I've tried to different gig-e cards,
both 82543, and both act the same way.

	Thanks,
	Jon
