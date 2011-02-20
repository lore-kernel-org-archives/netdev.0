From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about tg3 and bnx2 driver suppliers
Date: Sun, 20 Feb 2011 20:17:00 +0100
Message-ID: <1298229420.8559.59.camel@edumazet-laptop>
References: <3BA51C2C-B28F-4FED-BF5D-B9BF46EAF3F7@highwire.stanford.edu>
	 <1297952255.2604.115.camel@edumazet-laptop>
	 <4D615B2D.5080804@neli.hopto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Durket <durket@highwire.stanford.edu>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Micha Nelissen <micha@neli.hopto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59861 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256Ab1BTTRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 14:17:09 -0500
Received: by fxm17 with SMTP id 17so844893fxm.19
        for <netdev@vger.kernel.org>; Sun, 20 Feb 2011 11:17:07 -0800 (PST)
In-Reply-To: <4D615B2D.5080804@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 20 f=C3=A9vrier 2011 =C3=A0 19:19 +0100, Micha Nelissen a =C3=
=A9crit :
> Eric Dumazet wrote:
> > One possible cause of packet drops is when softirqs are disabled fo=
r too
> > long periods, even if NIC has a big RX ring (check ethtool -g eth0)
>=20
> Why aren't the softirqs converted to workqueues? Wouldn't that cut=20
> dependencies to other softirq users and improve latency?
>=20

Because it was done like that in the old days.

Its a bit less important these days, now typical machines have 8+ cpus.
Each device interrupt can be handled by its own cpu :)





