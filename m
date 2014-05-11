From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next,v2] Add support for netvsc build without
 CONFIG_SYSFS flag
Date: Sun, 11 May 2014 14:07:05 +0100
Message-ID: <1399813625.11946.138.camel@deadeye.wl.decadent.org.uk>
References: <1399581693-25050-1-git-send-email-haiyangz@microsoft.com>
	 <20140508.164458.157597820665207475.davem@davemloft.net>
	 <b641d25465f44cae8c7c9a680a31594d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tQ+SrHmhpjTwbQO9M2f8"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60334 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755717AbaEKNHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 09:07:24 -0400
In-Reply-To: <b641d25465f44cae8c7c9a680a31594d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tQ+SrHmhpjTwbQO9M2f8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-05-08 at 20:50 +0000, Haiyang Zhang wrote:
>=20
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Thursday, May 8, 2014 4:45 PM
> > To: Haiyang Zhang
> > Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> > jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> > devel@linuxdriverproject.org
> > Subject: Re: [PATCH net-next,v2] Add support for netvsc build without
> > CONFIG_SYSFS flag
> >=20
> > From: Haiyang Zhang <haiyangz@microsoft.com>
> > Date: Thu,  8 May 2014 13:41:33 -0700
> >=20
> > > +static inline void netvsc_record_rx_queue(struct sk_buff *skb,
> > > +					  struct hv_netvsc_packet *packet,
> > > +					  struct net_device *ndev)
> > > +{
> > > +#ifdef CONFIG_SYSFS
> > > +	skb_record_rx_queue(skb, packet->channel->
> > > +			    offermsg.offer.sub_channel_index %
> > > +			    ndev->real_num_rx_queues);
> > > +#endif
> > > +}
> >=20
> > This is still fantastically gross, what is so unique about your driver =
that it needs
> > hacks like this?  No other driver to my knowledge does.
> >=20
> > Figure out what it is that makes your driver so unique, and try to make=
 it
> > conform to how other drivers handle these features without SYSFS ifdef'=
ery
> > instead.
> >=20
>=20
> I looked around the other drivers, and the netif_set_real_num_rx_queues()=
 function.=20
> It's already switched to no-op without CONFIG_SYSFS flag. So I will rely =
on this, and=20
> don't have to handle the flag in my code.=20

I think most other drivers have a 1-1 mapping between hardware RX queues
and the RX queue indices reported to Linux.  It appears that in this
case sub_channel_index is the 'hardware' queue number, but you think
there is not a 1-1 mapping.  Why is that?

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.

--=-tQ+SrHmhpjTwbQO9M2f8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU292Aee/yOyVhhEJAQqpxw/+PepH36TUsPA/uUA2a7fJ4E+kV97YODHG
MJnJ77V9TakhYroX+YwqDDcpKrH+28hvQOO+2+liLi/QDD8HMrB6IQUzQhAUJW5Z
m8b1g9vU0pu89AGCCAR1e9LKcEBnq1Cm8qNRIIx2OagyKFmJrMnLeWYOgWtYl+TP
wml40YcKZUFlYmTDUIIN6q6qxnKj7mAvIO9mzD4VDZdWLmihbLcI7/Gj0eG5Tj1y
KFuZ5wDOn127lna2r/J6tTH9B8D4Srkscu1EZuwIxRVnZBTvSwmm/CGkvrcereXO
zvoLekpzGu8rFHE/7DHcMgqHqM+ZXZxfE2hpg60YHhKEJkJOnudDe8eOpaH9xQPI
qxsNF33MXVjKfaRIv9yyon1pyHJtU68i/mwy/6V80Pr/aS+44I1bqrZ/sQ54JMI4
+uyKVNqLNYxwm+YFraNfn2TbOLSgCElC7uOFMTuNIOSRmXrjb+NZ0XbZKdbbUJzA
ODH/xni4Hfl7cvQYVnMKlDpbzCqUz4sfov9gOuz6jKkr/VNBeVFAewjLhwfWEF5e
yXp4VaVmiB1RH1N/ZiGgsTujiMU61UYpJe5rooZ6hqo57fw2eL2F34ew7ww2bytU
FoiCtP6whtt2Vyr55hp0RUpfzKC0jb3Es+nYsmPFvAJIWbV7dMiyDibwf6n0t6fe
gzBv/Sg/hRI=
=iKqI
-----END PGP SIGNATURE-----

--=-tQ+SrHmhpjTwbQO9M2f8--
