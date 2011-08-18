From: Augusto Salazar <elpirata2000@yahoo.com>
Subject: network protocol
Date: Thu, 18 Aug 2011 10:07:04 -0700 (PDT)
Message-ID: <1313687224.8224.YahooMailNeo@web110315.mail.gq1.yahoo.com>
Reply-To: Augusto Salazar <elpirata2000@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm15-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.208]:46691 "HELO
	nm15-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750798Ab1HRRMa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 13:12:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,



How do I create a protocol that caches all the traffic, the incomming b=
efore any other protocol, and outgoing before going to the lower layer?

Why do I need this? because I want to modify the packets,

=46or example:
=A0add vlan tags to incomming packets so my vlan aware linux handles th=
em and remove them on the way out so my non vlan aware pc can handle th=
e packet.

I created a module using dev_add_pack, it works well as a sniffer but i=
t does not prevent the other protocols from getting the packet.

As a test after the "sniffing" I called netif_rx insted of destroying t=
he packet, I endeed up in a loop where I get one packet, sended to proc=
ess and get back again ( at least that is how I understand it).

Any idea of how to do this?

I am hoping to achieve this without patching the kernel.
=A0
BR,
AUGUSTO SALAZAR
