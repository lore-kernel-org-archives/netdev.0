From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Mon, 14 Mar 2011 19:33:28 +0000
Message-ID: <1300131208.32696.24.camel@localhost.localdomain>
References: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
	 <1300129032.3423.170.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:64613 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867Ab1CNTdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 15:33:43 -0400
In-Reply-To: <1300129032.3423.170.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-14 at 18:57 +0000, Eric Dumazet wrote:
> Le lundi 14 mars 2011 =E0 14:27 +0000, Ian Campbell a =E9crit :

> > +	/* Statistics */
> > +	unsigned long rx_gso_checksum_fixup;
>=20
> this is an "unsigned long" field

> > +static void xenvif_get_ethtool_stats(struct net_device *dev,
> > +				     struct ethtool_stats *stats, u64 * data)
> > +{
> > +	void *vif =3D netdev_priv(dev);
> > +	int i;
> > +
> > +	for (i =3D 0; i < ARRAY_SIZE(xenvif_stats); i++)
> > +		data[i] =3D *(int *)(vif + xenvif_stats[i].offset);
>=20
> so use : data[i] =3D *(unsigned long *)(vif + xenvif_stats[i].offset)=
;

Oops, will do, thanks.

Ian.


