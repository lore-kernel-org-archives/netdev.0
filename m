From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 03/41]bnx2x: MSI support
Date: Thu, 12 Feb 2009 22:37:38 +0200
Message-ID: <1234471059.4798.7.camel@lb-tlvb-eliezer>
References: <1234463775.1863.134.camel@lb-tlvb-eliezer>
 <1234464759.3583.8.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4355 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759113AbZBLUh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 15:37:59 -0500
In-Reply-To: <1234464759.3583.8.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-12 at 10:52 -0800, Ben Hutchings wrote:
Hi Ben!

It's always a pleasure to see how fast you respond. I really appreciate
the fact that you take the time to review my patches. Thanks!

> On Thu, 2009-02-12 at 20:36 +0200, Eilon Greenstein wrote:
> [...]
> > @@ -5359,9 +5360,28 @@
> >  #define PCICFG_PM_CSR_STATE			(0x3<<0)
> >  #define PCICFG_PM_CSR_PME_ENABLE		(1<<8)
> >  #define PCICFG_PM_CSR_PME_STATUS		(1<<15)
> > +#define PCICFG_MSI_CAP_ID				0x58
> 
> This appears to be a capability offset, not a capability id!  You might
> also consider not hard-coding it.

You are right - those are the offset for this device. I find it easier to
debug when I have the offsets at hand without the need to parse the
capabilities linked list. Since the offsets will not change for this
generation of chips, I don't see the harm in providing the explicit
offsets. I assume that the driver will require major changes for a new
generation even if I will use the capabilities ID... In any case, those
new values are listed just to help - they are not really used (though I
do use some of the other values in that area)

> > +#define PCICFG_MSI_CONTROL_ENABLE		(0x1<<16)
> > +#define PCICFG_MSI_CONTROL_MCAP 		(0x7<<17)
> > +#define PCICFG_MSI_CONTROL_MENA 		(0x7<<20)
> > +#define PCICFG_MSI_CONTROL_64_BIT_ADDR_CAP	(0x1<<23)
> > +#define PCICFG_MSI_CONTROL_MSI_PVMASK_CAPABLE	(0x1<<24)
> >  #define PCICFG_GRC_ADDRESS				0x78
> >  #define PCICFG_GRC_DATA 				0x80
> > +#define PCICFG_MSIX_CAP_ID				0xa0
> [...]
> 
> Similarly for this.
> 
> Ben.
> 


