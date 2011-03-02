From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's
	source MAC
Date: Wed, 2 Mar 2011 20:30:04 +0800
Message-ID: <20110302123004.GA21002@gondor.apana.org.au>
References: <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com> <20110301023525.GK11864@gospo.rdu.redhat.com> <9882.1298958366@death> <20110301181624.GM11864@gospo.rdu.redhat.com> <4D6D658C.90300@gmail.com> <20893.1299018331@death> <4D6D7C66.6050205@gmail.com> <AANLkTi=QTDNBf7Jskj55NP64Os8kgEs1WMpFGHMo+K3B@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47684 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756435Ab1CBMa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 07:30:27 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=QTDNBf7Jskj55NP64Os8kgEs1WMpFGHMo+K3B@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2011 at 11:10:07AM +0100, Nicolas de Peslo=FCan wrote:
>
> If one decide to configure two interfaces with the same MAC and conne=
ct them
> to the same LAN, then we get the exact same situation. Having eth0 an=
d eth1
> share a single MAC and a single IP address, connected to a switch in
> Etherchannel mode is a perfectly valid setup, while suboptimal. And i=
f the
> Etherchannel mode happens to be improperly configured, we end up with=
 the
> same problem as reported by Andy.

Right.  There's also the case where you have other MAC addresses
sitting behind the bonding device, e.g., virtualisation.  So basing
it purely on the bonding device's MAC address is probably not worth
the trouble.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
