From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 0/2] pegasus: correct buffer sizes
Date: Wed, 27 Apr 2016 09:46:15 +0200
Message-ID: <1461743175.3723.1.camel@sipsolutions.net>
References: <1461742525-2748-1-git-send-email-petkan@mip-labs.com>
	 (sfid-20160427_093549_878302_3DDEE29D)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, a1291762@gmail.com
To: Petko Manolov <petkan@mip-labs.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49744 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbcD0HqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 03:46:21 -0400
In-Reply-To: <1461742525-2748-1-git-send-email-petkan@mip-labs.com> (sfid-20160427_093549_878302_3DDEE29D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-27 at 10:35 +0300, Petko Manolov wrote:
>=C2=A0
> Nearly all Pegasus devices may append the RX status to the end of the
> received =C2=A0packet.=C2=A0=C2=A0It is the default setup for the dri=
ver.=C2=A0=C2=A0The
> actual ethernet packet is =C2=A04 bytes shorter.=C2=A0=C2=A0Why and w=
hen 'pkt_len -=3D
> 4' became 'pkt_len -=3D 8' is again hidden in the mists of time.=C2=A0=
=C2=A0There
> might have been a good reason to do so, but multiple reads of the
> datasheet did not point me to any.
>=20

Wild guess: (some) devices pass the FCS, perhaps depending on the
configuration?

johannes
