From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 17:48:14 +0100
Message-ID: <1298911694.2941.639.camel@edumazet-laptop>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	 <1298793252.8726.45.camel@edumazet-laptop>
	 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
	 <1298837273.8726.128.camel@edumazet-laptop>
	 <20110228161115.GB2515@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Albert Cahalan <acahalan@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59759 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755576Ab1B1QsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 11:48:20 -0500
In-Reply-To: <20110228161115.GB2515@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 f=C3=A9vrier 2011 =C3=A0 11:11 -0500, John W. Linville a =C3=
=A9crit :
> On Sun, Feb 27, 2011 at 09:07:53PM +0100, Eric Dumazet wrote:
>=20
> > Qdisc should return to caller a good indication packet is queued or
> > dropped at enqueue() time... not later (aka : never)
> >=20
> > Accepting a packet at t0, and dropping it later at t0+limit without
> > giving any indication to caller is a problem.
>=20
> Can you elaborate on what problem this causes?  Is it any worse than
> if the packet is dropped at some later hop?
>=20
> Is there any API that could report the drop to the sender (at
> least a local one) without having to wait for the ack timeout?
> Should there be?
>=20

Not all protocols have ACKS ;)

dev_queue_xmit() returns an error code, some callers use it.



