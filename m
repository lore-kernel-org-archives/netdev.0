From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/9] Removed bogus 'fall-thru' comments
Date: Fri, 9 May 2008 13:12:07 +0100
Message-ID: <20080509121206.GE13470@solarflare.com>
References: <20080507114121.GL2217@solarflare.com> <20080507115657.GO2217@solarflare.com> <Pine.LNX.4.64.0805072328570.23091@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:60922 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753944AbYEIMM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 08:12:27 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805072328570.23091@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Wed, 7 May 2008, Ben Hutchings wrote:
>=20
> > Fall-through is expected outside a switch statement.
> >=20
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> >  drivers/net/sfc/falcon.c |    2 --
> >  drivers/net/sfc/rx.c     |    1 -
> >  2 files changed, 0 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
> > index 46db549..9cac344 100644
> > --- a/drivers/net/sfc/falcon.c
> > +++ b/drivers/net/sfc/falcon.c
> > @@ -2468,14 +2468,12 @@ int falcon_probe_nic(struct efx_nic *efx)
> >   fail5:
> >  	falcon_free_buffer(efx, &efx->irq_status);
> >   fail4:
> > -	/* fall-thru */
> >   fail3:
> >  	if (nic_data->pci_dev2) {
> >  		pci_dev_put(nic_data->pci_dev2);
> >  		nic_data->pci_dev2 =3D NULL;
> >  	}
> >   fail2:
> > -	/* fall-thru */
> >   fail1:
> >  	kfree(efx->nic_data);
> >  	return rc;
>=20
> Is there really any point in keeping those extra goto targets? I'd su=
ggest=20
> that you simply eliminate the extra ones completely.

I think we'll do that at some point, along with giving them meaningful
names rather than numbers.  But not right now.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
