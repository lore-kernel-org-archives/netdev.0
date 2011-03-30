From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: mcast snooping, fix IPv6 MLD checksum
 calculation
Date: Wed, 30 Mar 2011 02:29:24 -0700 (PDT)
Message-ID: <20110330.022924.52196184.davem@davemloft.net>
References: <20110327034404.GC31916@Sellars>
	<1301207244-10428-1-git-send-email-linus.luessing@web.de>
	<1301207244-10428-2-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, shemminger@linux-foundation.org,
	yoshfuji@linux-ipv6.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: linus.luessing@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53321
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134Ab1C3JaC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2011 05:30:02 -0400
In-Reply-To: <1301207244-10428-2-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=FCssing <linus.luessing@web.de>
Date: Sun, 27 Mar 2011 08:27:23 +0200

> In contrast to IGMP, the MLDv1/2 message checksum needs to include an
> IPv6 "pseudo-header" in the calculations (see RFC2710, section 3.3;
> RFC3810, section 5.1.2).
>=20
> The multicast snooping feature of the bridge code however did not tak=
e
> this "pseudo-header" into consideration for the checksum validation w=
hen
> parsing a snooped IPv6 MLDv1/2 message of another host, leading to
> possibly ignored, though valid MLDv1/2 messages. This commit shall fi=
x
> this issue.
>=20
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

I'm waiting for am updated version of this patch which addresses Herber=
t
Xu's feedback.
