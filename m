From: "Marc St-Onge" <marc.st-onge@canadiansignals.com>
Subject: Multicast GRE changed behaviour
Date: Mon, 16 Feb 2015 20:17:53 -0500
Message-ID: <003301d04a4f$8e1691e0$aa43b5a0$@canadiansignals.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtpa07-02.prod.phx3.secureserver.net ([173.201.192.231]:38314
	"EHLO p3plsmtpa07-02.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751277AbbBQBYy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2015 20:24:54 -0500
References: 
In-Reply-To: 
Content-Language: en-ca
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not 100% sure if the issue we are facing is related to recent chang=
es in
ip_gre.c but while I was reading through the code I came about the comm=
ent
on line 341 and suspect some changes may have been introduced in ip_gre=
=2Ec.
We have been using Multicast GRE tunnels in our organisation (we actual=
ly
call it Broadcast GRE and have given it the BGRE acronym) but essential=
ly,
we successfully setup the tunnels exactly as described in the example.

The recent Ubuntu upgrade has caused an backward compatibility issue
somewhere between kernel 3.8 and 3.13. The previous kernel would use
Multicast to do the ARP and discovery as well as encapsulation of Multi=
cast
user traffic and would use the end-point Unicast address to encapsulate=
 the
Unicast user traffic between the remote nodes.=A0 In Kernel 3.13 we are
observing that the Unicast traffic is also encapsulated in a Multicast
datagram.


Marc St-Onge
