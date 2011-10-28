From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v4 0/9] Cleanup and extension of netdev features
Date: Fri, 28 Oct 2011 23:47:12 +0200
Message-ID: <20111028214712.GA1787@rere.qmqm.pl>
References: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
 <1319513754.3834.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38198 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933414Ab1J1VrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Oct 2011 17:47:15 -0400
Content-Disposition: inline
In-Reply-To: <1319513754.3834.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 25, 2011 at 05:35:54AM +0200, Eric Dumazet wrote:
> Le mardi 25 octobre 2011 =C3=A0 02:36 +0200, Micha=C5=82 Miros=C5=82a=
w a =C3=A9crit :
> > Commit fd38f734 (igbvf: convert to ndo_fix_features) removed last u=
se
> > of old ethtool ops for controlling netdevice's features. This serie=
s
> > finishes the cleanup and extends feature pool to 64 bits.
> >=20
> > Also, there's additional patch that removes NETIF_F_NO_CSUM as it i=
s
> > now, and has been for some time, equivalent to NETIF_F_HW_CSUM.
> >=20
> > To see the new features in action, you need ethtool patched with:
> >=20
> > http://patchwork.ozlabs.org/patch/96374/
> >=20
> > Not much has changed in those patches compared to last version I po=
sted
> > in June.
> This reminds me current net-next is busted for bond/vlan, I dont know
> why.
[cut ethtool output]

Sorry for late reply. Is it broken also for bridge? Those two drivers s=
hare
almost the same code that propagates features.

Best Regards,
Micha=C5=82 Miros=C5=82aw
