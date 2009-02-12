From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 03/41]bnx2x: MSI support
Date: Thu, 12 Feb 2009 20:47:48 +0000
Message-ID: <1234471668.3583.26.camel@achroite>
References: <1234463775.1863.134.camel@lb-tlvb-eliezer>
	 <1234464759.3583.8.camel@achroite>
	 <1234471059.4798.7.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:54526 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758877AbZBLUr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 15:47:56 -0500
In-Reply-To: <1234471059.4798.7.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-12 at 22:37 +0200, Eilon Greenstein wrote:
> On Thu, 2009-02-12 at 10:52 -0800, Ben Hutchings wrote:
> Hi Ben!
> 
> It's always a pleasure to see how fast you respond. I really appreciate
> the fact that you take the time to review my patches. Thanks!
> 
> > On Thu, 2009-02-12 at 20:36 +0200, Eilon Greenstein wrote:
> > [...]
> > > @@ -5359,9 +5360,28 @@
> > >  #define PCICFG_PM_CSR_STATE			(0x3<<0)
> > >  #define PCICFG_PM_CSR_PME_ENABLE		(1<<8)
> > >  #define PCICFG_PM_CSR_PME_STATUS		(1<<15)
> > > +#define PCICFG_MSI_CAP_ID				0x58
> > 
> > This appears to be a capability offset, not a capability id!  You might
> > also consider not hard-coding it.
> 
> You are right - those are the offset for this device. I find it easier to
> debug when I have the offsets at hand without the need to parse the
> capabilities linked list. Since the offsets will not change for this
> generation of chips, I don't see the harm in providing the explicit
> offsets. I assume that the driver will require major changes for a new
> generation even if I will use the capabilities ID...

I agree, the run-time lookup is not really necessary.  But please fix
the name.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

