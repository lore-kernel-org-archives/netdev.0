From: =?iso-8859-2?Q?Micha=B3Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2] net: Fix too optimistic NETIF_F_HW_CSUM features
Date: Tue, 30 Nov 2010 18:07:55 +0100
Message-ID: <20101130170755.GA1798@rere.qmqm.pl>
References: <20101130163057.29978.92721.stgit@rechot.qmqm.pl> <1291136026.2904.135.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Gross <jesse@nicira.com>, Jon Mason <jon.mason@exar.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39878 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752246Ab0K3RH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 12:07:56 -0500
Content-Disposition: inline
In-Reply-To: <1291136026.2904.135.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 05:53:46PM +0100, Eric Dumazet wrote:
> Le mardi 30 novembre 2010 =C3=A0 17:38 +0100, Micha=C5=82Miros=C5=82a=
w a =C3=A9crit :
> > NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM,=
 but
> > some drivers miss the difference. Fix this and also fix UFO depende=
ncy
> > on checksumming offload as it makes the same mistake in assumptions=
=2E
> >=20
> > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> > ---
> >=20
> > Changes from v1:
> > - fixed compilation of jme driver
> > - enable vxge support for IPv6 checksum
> > ---
> >  drivers/net/vxge/vxge-ethtool.c |    2 +-
> >  drivers/net/vxge/vxge-main.c    |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> I have no idea how you got this diffstat.
> Your patch touches more files than that...

Hmm. Looks like a bug in StGit.

stg refresh didn't fix this. stg repair didn't either. :/

Best Regards,
Micha=C5=82 Miros=C5=82aw
