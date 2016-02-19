From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] ehea: Drop owner assignment from platform_driver
Date: Fri, 19 Feb 2016 07:06:46 -0500 (EST)
Message-ID: <alpine.DEB.2.10.1602190706200.2801@hadrien>
References: <20160219112219.GA2366@amitoj-Inspiron-3542> <20160219113524.GR4148@siri.cascardo.eti.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amitoj Kaur Chawla <amitoj1606@gmail.com>,
	cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160219113524.GR4148@siri.cascardo.eti.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 19 Feb 2016, Thadeu Lima de Souza Cascardo wrote:

> On Fri, Feb 19, 2016 at 04:52:19PM +0530, Amitoj Kaur Chawla wrote:
> > platform_driver does not need to set an owner, it will be populated by
> > the driver core.
> >
> > Generated-by: scripts/coccinelle/api/platform_no_drv_owner.cocci
> >
> > Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
> > ---
> >  drivers/net/ethernet/ibm/ehea/ehea_main.c | 1 -
> >  1 file changed, 1 deletion(-)
> >
> > diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> > index 2a0dc12..d4b022f 100644
> > --- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
> > +++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
> > @@ -127,7 +127,6 @@ static const struct of_device_id ehea_device_table[] = {
> >  static struct platform_driver ehea_driver = {
> >  	.driver = {
> >  		.name = "ehea",
> > -		.owner = THIS_MODULE,
> >  		.of_match_table = ehea_device_table,
> >  	},
> >  	.probe = ehea_probe_adapter,
> > --
> > 1.9.1
> >
>
> NACK.
>
> ehea does not use platform_driver_register, it uses
> ibmebus_register_driver, which does not set owner.

Thanks for the information.  I will try to update the saemantic patch.

julia
