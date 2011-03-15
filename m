From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] xen: netfront: ethtool stats fields should be unsigned
 long
Date: Tue, 15 Mar 2011 07:12:11 +0000
Message-ID: <1300173131.32696.44.camel@localhost.localdomain>
References: <1299776658-15137-1-git-send-email-ian.campbell@citrix.com>
	 <20110314.151029.200378268.davem@davemloft.net>
	 <1300161043.2649.33.camel@edumazet-laptop>
	 <20110314.210615.193717284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23432 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917Ab1COHMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 03:12:14 -0400
In-Reply-To: <20110314.210615.193717284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-15 at 04:06 +0000, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 15 Mar 2011 04:50:43 +0100
>=20
> > Le lundi 14 mars 2011 =E0 15:10 -0700, David Miller a =E9crit :
> >> From: Ian Campbell <ian.campbell@citrix.com>
> >> Date: Thu, 10 Mar 2011 17:04:18 +0000
> >>=20
> >> > Fixup the rx_gso_checksum_fixup field added in e0ce4af920eb to b=
e
> >> > unsigned long as suggested by Ben Hutchings in
> >> > <1298919198.2569.14.camel@bwh-desktop>
> >> >=20
> >> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> >>=20
> >> Applied, thanks Ian.
> >=20
> > Hmm, this needs this followup patch then.
> >=20
> > Thanks
> >=20
> > [PATCH] xen: netfront: fix xennet_get_ethtool_stats()
> >=20
> > commit e9a799ea4a5551d2 (xen: netfront: ethtool stats fields should=
 be
> > unsigned long) made rx_gso_checksum_fixup an unsigned long.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I even saw your feedback but for some reason I still applied
> his patch, sorry about that :-)
>=20
> Applied, thanks.

His feed back was for netback and this was a netfront patch, but I
didn't make the link either.

Thanks for picking it up Eric.

Ian.


