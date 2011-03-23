From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Fix possibly wrong MLD queries' ethernet
 source address
Date: Tue, 22 Mar 2011 19:26:54 -0700 (PDT)
Message-ID: <20110322.192654.246547109.davem@davemloft.net>
References: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
	<1300830032-6727-1-git-send-email-linus.luessing@web.de>
	<1300830032-6727-2-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: JBeulich@novell.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: linus.luessing@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56415
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755045Ab1CWC0P convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 22:26:15 -0400
In-Reply-To: <1300830032-6727-2-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=FCssing <linus.luessing@web.de>
Date: Tue, 22 Mar 2011 22:40:32 +0100

> The ipv6_dev_get_saddr() is currently called with an uninitialized
> destination address. Although in tests it usually seemed to neverthel=
ess
> always fetch the right source address, there seems to be a possible r=
ace
> condition.
>=20
> Therefore this commit changes this, first setting the destination
> address and only after that fetching the source address.
>=20
> Reported-by: Jan Beulich <JBeulich@novell.com>
> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

Applied, thank you!
