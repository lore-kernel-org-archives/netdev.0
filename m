From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 0/2] pegasus: correct buffer sizes
Date: Wed, 27 Apr 2016 11:44:05 +0200
Message-ID: <1461750245.3723.8.camel@sipsolutions.net>
References: <1461742525-2748-1-git-send-email-petkan@mip-labs.com>
	 <1461743175.3723.1.camel@sipsolutions.net> <20160427093358.GA30444@p310>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, a1291762@gmail.com
To: Petko Manolov <petkan@mip-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50255 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbcD0JoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 05:44:11 -0400
In-Reply-To: <20160427093358.GA30444@p310>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-27 at 12:33 +0300, Petko Manolov wrote:
>=C2=A0
> Your guess turned out to be not so wild.=C2=A0=C2=A0;)=C2=A0=C2=A0All=
 Pegasus devices are
> configured =C2=A0(by the driver) to append CRC at the end of each RX
> packet.=C2=A0=C2=A0However, the driver reports packet length that doe=
s not
> include it.=C2=A0=C2=A0

Interesting, then my guess was wrong though, since the length is
reported without it, or am I misunderstanding this?

> I doubt the appended CRC is being silently verified by the upper
> layer, bit i might be wrong of course.

It's even "outside" the skb as you describe it, so it can't even be
touched, no?

> Perhaps it is best if instruct the device to not include the CRC as
> it seems ignored anyway.

Yeah, there's no point in passing it over the bus.

johannes
