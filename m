From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch]  bondig - arp_interval with low value => Oops.
Date: Tue, 10 Jun 2008 18:19:40 -0400
Message-ID: <484EFDFC.3040206@garzik.org>
References: <482C9E73.2040202@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas 2P <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38924 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754732AbYFJWTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 18:19:49 -0400
In-Reply-To: <482C9E73.2040202@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas 2P wrote:
> When setting arp_interval parameter to a very low value, delta_in_tic=
ks=20
> for next arp might become 0, causing an infinite loop.
>=20
> See http://bugzilla.kernel.org/show_bug.cgi?id=3D10680
>=20
> Same problem for miimon parameter already fixed, but fix might be=20
> enhanced, by using msecs_to_jiffies() function.
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

I don't see an ACK from Jay in my mbox?

Certainly looks nicer than adding "? : 1" to each of the remaining two=20
cases.


