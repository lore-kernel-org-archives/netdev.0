From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Thu, 26 Aug 2010 13:57:07 +0200
Message-ID: <1282823827.2476.663.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
	 <20100823080543.319143e3@nehalam>
	 <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
	 <1282672647.2302.15.camel@achroite.uk.solarflarecom.com>
	 <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
	 <1282688441.22839.34.camel@localhost> <20100824153920.63360072@s6510>
	 <alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Marc Aurele La France <tsi@ualberta.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:39410 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab0HZL5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 07:57:19 -0400
In-Reply-To: <alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 ao=C3=BBt 2010 =C3=A0 05:40 -0600, Marc Aurele La France a =
=C3=A9crit :

> Steady now.  There's no need to YELL nor be arrogant.  You and I both=
 know=20
> there's a place for NFS over UDP.  That's not changing any time soon.=
  While=20
> I'm aware of the issue you brought up, it is separate from the one at=
 hand in=20
> this discussion.
>=20
> I do want to thank you, however, for reminding me of TCP.  It's somet=
hing=20
> 20/20 hindsight says I should have checked out before starting this t=
hread.=20
> Logistically, it'll be a few days before I can do so though.  If that=
 allows=20
> me to increase the MTU all the way up to 65520, then this UDP thing w=
ill=20
> likely remain unresolved.
>=20

Unfortunately, your infiniband device lacks NETIF_F_SG support.

MTU a bit larger than PAGE_SIZE-overhead will need high order
allocations ?



