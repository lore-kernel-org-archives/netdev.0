From: Thadeu Lima de Souza Cascardo <cascardo@debian.org>
Subject: Re: [PATCH] ehea: Drop owner assignment from platform_driver
Date: Fri, 19 Feb 2016 10:15:08 -0200
Message-ID: <20160219121501.GS4148@siri.cascardo.eti.br>
References: <20160219112219.GA2366@amitoj-Inspiron-3542>
 <20160219113524.GR4148@siri.cascardo.eti.br>
 <alpine.DEB.2.10.1602190706200.2801@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitoj Kaur Chawla <amitoj1606@gmail.com>,
	cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trem.minaslivre.org ([148.251.208.85]:55127 "EHLO
	grilo.cascardo.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992987AbcBSMPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 07:15:18 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602190706200.2801@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2016 at 07:06:46AM -0500, Julia Lawall wrote:
> On Fri, 19 Feb 2016, Thadeu Lima de Souza Cascardo wrote:
> > On Fri, Feb 19, 2016 at 04:52:19PM +0530, Amitoj Kaur Chawla wrote:
> > > platform_driver does not need to set an owner, it will be populated by
> > > the driver core.
> > >
> > > Generated-by: scripts/coccinelle/api/platform_no_drv_owner.cocci
> > >
> > > Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> > > ---
> > >  drivers/net/ethernet/ibm/ehea/ehea_main.c | 1 -
> > >  1 file changed, 1 deletion(-)
> > >
> > > diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> > > index 2a0dc12..d4b022f 100644
> > > --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> > > +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> > > @@ -127,7 +127,6 @@ static const struct of_device_id ehea_device_table[] = {
> > >  static struct platform_driver ehea_driver = {
> > >  	.driver = {
> > >  		.name = "ehea",
> > > -		.owner = THIS_MODULE,
> > >  		.of_match_table = ehea_device_table,
> > >  	},
> > >  	.probe = ehea_probe_adapter,
> > > --
> > > 1.9.1
> > >
> >
> > NACK.
> >
> > ehea does not use platform_driver_register, it uses
> > ibmebus_register_driver, which does not set owner.
> 
> Thanks for the information.  I will try to update the saemantic patch.
> 
> julia

Thanks, Julia. I appreciate your work on that.

Cascardo.
