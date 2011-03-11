From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 2/8] macb: detect hclk presence from platform data
Date: Fri, 11 Mar 2011 13:47:57 +0100
Message-ID: <20110311124757.GK9351@game.jcrosoft.org>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-3-git-send-email-jamie@jamieiles.com>
 <20110311014400.GJ9351@game.jcrosoft.org>
 <20110311085443.GJ6198@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 64.mail-out.ovh.net ([91.121.185.65]:51353 "HELO
	64.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753011Ab1CKMx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 07:53:27 -0500
Content-Disposition: inline
In-Reply-To: <20110311085443.GJ6198@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08:54 Fri 11 Mar     , Jamie Iles wrote:
> On Fri, Mar 11, 2011 at 02:44:00AM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > On 10:10 Thu 10 Mar     , Jamie Iles wrote:
> > > +#ifdef CONFIG_ARCH_AT91
> > > +#define PCLK_NAME	"macb_clk"
> > > +#else /* CONFIG_ARCH_AT91 */
> > > +#define PCLK_NAME	"pclk"
> > > +#endif
> > 
> > we need change the clock name and avoid the ifdef
> > so this will be generic
> > 
> > nb I work on the switch to clkdev currently for avr32 and at91
> 
> This should be gone now.  Russell made the suggestion to have a fake clk 
> for hclk on AT91 so I think I've solved that now.  There's an updated 
> patch in my reply to Russell's message but essentially I'm using 
> at91_clock_associate() to turn "macb_pclk" into "hclk" and "pclk".  Does 
> this seem reasonable?
please do not use at91_clock_associate as I'm going to remove it as use static
clock as done on shmobile as example
so if it's a fake clock please as ochi_clk on 9g45

Best Regards,
J.
