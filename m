From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] r8169: add D-Link DGE-560T identifiers.
Date: Wed, 29 Aug 2012 23:36:31 -0700
Message-ID: <1346308591.17040.20.camel@deadeye.wl.decadent.org.uk>
References: <20120829194037.GB6389@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Neyuki Inaya <in@joblog.ru>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16846 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751715Ab2H3Gge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 02:36:34 -0400
In-Reply-To: <20120829194037.GB6389@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-29 at 21:40 +0200, Francois Romieu wrote:
> This one includes a 8168. Not to be confused with the sky2 driven
> one whose PCI vendor and device ID are the same.
>
> Reported-by: Neyuki Inaya <in@joblog.ru>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
> 
>  The patch applies to Linus's branch as well.
> 
>  drivers/net/ethernet/realtek/r8169.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index b47d5b3..ab1cc56 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -288,6 +288,8 @@ static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
>  	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8168), 0, 0, RTL_CFG_1 },
>  	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), 0, 0, RTL_CFG_0 },
>  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), 0, 0, RTL_CFG_0 },
> +	{ PCI_VENDOR_ID_DLINK,			0x4300,
> +		PCI_VENDOR_ID_DLINK, 0x4b10,		 0, 0, RTL_CFG_1 },

This has no effect, as the preceding entry will match all the same
devices.  I think you need to insert it before that.

Ben.

>  	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4302), 0, 0, RTL_CFG_0 },
>  	{ PCI_DEVICE(PCI_VENDOR_ID_AT,		0xc107), 0, 0, RTL_CFG_0 },
>  	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
