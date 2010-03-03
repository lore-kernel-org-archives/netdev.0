From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Wed, 03 Mar 2010 15:31:18 +0100
Message-ID: <1267626678.2997.25.camel@edumazet-laptop>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
	 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
	 <1267606433.2997.4.camel@edumazet-laptop>
	 <1267607162.2370.169.camel@debian>
	 <1267610843.2997.7.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6999@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: "Zhu, Yi" <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:49594 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371Ab0CCOdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:33:10 -0500
Received: by bwz1 with SMTP id 1so49750bwz.21
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 06:33:08 -0800 (PST)
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860A45A6999@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 22:12 +0800, Zhu, Yi a =C3=A9crit :
> Eric Dumazet [mailto:eric.dumazet@gmail.com] wrote:
> > Le mercredi 03 mars 2010 =C3=A0 17:06 +0800, Zhu Yi a =C3=A9crit :
>=20
> >> I simply follow how the code is originally written. As you can see=
,
> >> tcp_v4_do_rcv() doesn't always do so. And in the backlog queuing p=
lace,
> >> we don't even bother to check.
>=20
> > You add a new point where a packet can be dropped, this should be
> > accounted for, so that admins can have a clue whats going on.
>=20
> > Previously, packet was always queued, and dropped later (and accoun=
ted)
>=20
> In case of the skb doesn't have a MD5 option while we are expecting o=
ne, or we
> failed to find the sk for the skb connection request, etc, the skb is=
 dropped silently in
> tcp_v4_do_rcv(). No?

Then its a separate bug. MD5 support added so many bugs its not even
funny.

Existing bugs are not an excuse for adding new ones, we try the reverse=
=2E
No ?



