From: "Steve Iribarne" <steve.iribarne@dilithiumnetworks.com>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Thu, 10 Mar 2005 06:35:43 -0800
Message-ID: <B8561865DB141248943E2376D0E85215FFE3D6@DHOST001-17.DEX001.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hadi@cyberus.ca>, "Henrik Nordstrom" <hno@marasystems.com>,
	"Martin Mares" <mj@ucw.cz>, "Zdenek Radouch" <zdenek@rcn.com>,
	"Eran Mann" <emann@mrv.com>, "Thomas Graf" <tgraf@suug.ch>,
	"Andi Kleen" <ak@muc.de>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Catalin\(ux aka Dino\) BOIE" <util@deuroconsult.ro>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-> You say that a client will not allow you to use net 10.
-> OK, but, the same client would not allow you to use 127/8 because
they
-> use
-> it!
-> What I'm saying is that 10.0.0.0/8 and 127.0.0.0/8 are the same. The
-> customer can use them.
-> You assume that the client will not use 127/8. Why? This is wrong.
-> You can use it, the client can use it.
-> 

No.  If the client uses 127/8 on a linux box, it is just a loopback and
will never go out on the wire and the applications (i.e. telnet, ftp,
ping, whatever) will just loopback.

