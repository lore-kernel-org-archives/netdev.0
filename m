From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v3 3/6] can: make struct proto const
Date: Tue, 15 Mar 2011 23:19:16 +0100
Message-ID: <1300227556.2565.9.camel@edumazet-laptop>
References: <20110314132004.GA333@e-circ.dyndns.org>
	 <20110314134721.GD333@e-circ.dyndns.org>
	 <1300111755.3423.20.camel@edumazet-laptop>
	 <20110314150227.GJ333@e-circ.dyndns.org>
	 <1300120943.3423.121.camel@edumazet-laptop>
	 <20110314171752.GL333@e-circ.dyndns.org>  <4D7FD9ED.1080004@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34069 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab1COWTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 18:19:23 -0400
Received: by bwz15 with SMTP id 15so1023214bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 15:19:22 -0700 (PDT)
In-Reply-To: <4D7FD9ED.1080004@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 mars 2011 =C3=A0 22:28 +0100, Oliver Hartkopp a =C3=A9crit =
:

> Hello Eric,
>=20
> the RCU code in phonet is worth to consider. But loading and removing=
 of
> protocols is far away from being a hot path ... what would be the adv=
antages
> to move to RCU here?
>=20

can_create() could avoid taking the spinlock.

I have no idea if its a critical path, I guess not.


