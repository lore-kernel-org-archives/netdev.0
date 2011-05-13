From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bridge] [PATCH] bridge: fix forwarding of IPv6
Date: Fri, 13 May 2011 13:24:29 -0700
Message-ID: <20110513132429.261785c4@nehalam>
References: <20110510233540.GJ6397@morgul.net>
	<20110513125314.66861b31@nehalam>
	<1305316844.3120.8.camel@edumazet-laptop>
	<20110513.160232.1127228366429050055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, noahm@debian.org,
	bridge@lists.linux-foundation.org, herbert@gondor.hengli.com.au,
	ben@decadent.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47665 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758906Ab1EMUYc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:24:32 -0400
In-Reply-To: <20110513.160232.1127228366429050055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 May 2011 16:02:32 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 13 May 2011 22:00:44 +0200
>=20
> > Le vendredi 13 mai 2011 =C3=A0 12:53 -0700, Stephen Hemminger a =C3=
=A9crit :
> >> The commit 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e
> >>     bridge: Reset IPCB when entering IP stack on NF_FORWARD
> >> broke forwarding of IPV6 packets in bridge because it would
> >> call bp_parse_ip_options with an IPV6 packet.
> >>=20
> >> Reported-by: Noah Meyerhans <noahm@debian.org>
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >>=20
> >> ---
> >> Patch against net-next-2.6 but must be applied to net-2.6
> >> and stable as well
> >>=20
> >=20
> > Well, stable is not needed, since faulty commit is not in 2.6.38
> >=20
> > Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I do need to queue it up for -stable because the faulty commit is
> also queued up there :-)

The faulty commit was in 2.6.38.4
