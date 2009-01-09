From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Fri, 9 Jan 2009 09:58:35 -0500
Message-ID: <20090109144414.GA12445@hmsreliant.think-freely.org>
References: <1231446610.3893.17.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41161 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbZAIO6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 09:58:48 -0500
Content-Disposition: inline
In-Reply-To: <1231446610.3893.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 08:30:10PM +0000, Ben Hutchings wrote:
> Following the removal of the unused struct net_device * parameter fro=
m
> the NAPI functions named *netif_rx_* in commit 908a7a1, they are
> exactly equivalent to the corresponding *napi_* functions and are
> therefore redundant.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> =EF=BB=BFNeil Horman <nhorman@tuxdriver.com> wrote
> re: [PATCH] netpoll: fix race on poll_list resulting in garbage entry=
:
> > On Wed, Dec 17, 2008 at 07:29:36PM -0800, David Miller wrote:
> > > From: Neil Horman <nhorman@tuxdriver.com>
> > > Date: Wed, 17 Dec 2008 20:13:06 -0500
> > >=20
> > > > Ok, here you go, one omnibus patch
> > >=20
> > > This doesn't apply to net-next-2.6, not even by a country mile.
> > > :-)
> > >=20
> > > Please respin this, thanks.
> >=20
> >=20
> > Respun, and diffeed against the head of net-next-2.6.git
> >=20
> > Since we migrated the napi polling infrastructure out of the net_de=
vice
> > structure, the netif_rx_[prep|schedule|complete] api has taken a ne=
t_device
> > structure pointer, which in all cases goes unused.  This patch modi=
fies the api
> > to remove that parameter, and fixes up all the required call sites.
> [...]
>=20
> I revisited this to update the out-of-tree version of the sfc driver.
> This makes the *netif_rx_* functions equivalent to the corresponding
> *napi_* functions.  So let's finish the job.  This is another search-
> and-replace, mostly compile-tested.
>=20
> Ben.
>=20

Makes sense to me
Acked-by: Neil Horman <nhorman@tuxdriver.com>


