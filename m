From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] ethtool: Add PHY statistics support
Date: Sun, 13 Mar 2016 17:08:48 +0100
Message-ID: <20160313160848.GG9674@lunn.ch>
References: <1450871911-19509-1-git-send-email-andrew@lunn.ch>
 <1450871911-19509-3-git-send-email-andrew@lunn.ch>
 <1457884216.3331.16.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55739 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbcCMQIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2016 12:08:50 -0400
Content-Disposition: inline
In-Reply-To: <1457884216.3331.16.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +.B ethtool \-I|\-\-phy-statistics
> > +.I devname
> > +.HP
>=20
> -I isn't a useful mnemonic, so I will drop the short option altogethe=
r.

It was the best i could come up with. -P would of been nice, since we
have -S for MAC statistics, but that is taken. PHY sounds a bit like
I, so why not. But i'm O.K. for -I to be dropped.
=20
> > +	/* todo - pretty-print the strings per-driver */
> > +	fprintf(stdout, "PHY statistics:\n");
> > +	for (i =3D 0; i < n_stats; i++) {
> > +		fprintf(stdout, "=A0=A0=A0=A0=A0%.*s: %llu\n",
> > +			ETH_GSTRING_LEN,
> > +			&strings->data[i * ETH_GSTRING_LEN],
> > +			stats->data[i]);
> > +	}
> > +	free(strings);
> > +	free(stats);
> > +
> > +	return 0;
> > +}
>=20
> This is basically a copy-paste of do_gstats() so they should be merge=
d
> into one function.

O.K, i can do that.

     Andrew
