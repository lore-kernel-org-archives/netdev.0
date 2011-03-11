From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH 2/8] macb: detect hclk presence from platform data
Date: Fri, 11 Mar 2011 08:54:43 +0000
Message-ID: <20110311085443.GJ6198@pulham.picochip.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-3-git-send-email-jamie@jamieiles.com>
 <20110311014400.GJ9351@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35702 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298Ab1CKIyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 03:54:47 -0500
Received: by bwz15 with SMTP id 15so2511854bwz.19
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2011 00:54:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110311014400.GJ9351@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2011 at 02:44:00AM +0100, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On 10:10 Thu 10 Mar     , Jamie Iles wrote:
> > +#ifdef CONFIG_ARCH_AT91
> > +#define PCLK_NAME	"macb_clk"
> > +#else /* CONFIG_ARCH_AT91 */
> > +#define PCLK_NAME	"pclk"
> > +#endif
> 
> we need change the clock name and avoid the ifdef
> so this will be generic
> 
> nb I work on the switch to clkdev currently for avr32 and at91

This should be gone now.  Russell made the suggestion to have a fake clk 
for hclk on AT91 so I think I've solved that now.  There's an updated 
patch in my reply to Russell's message but essentially I'm using 
at91_clock_associate() to turn "macb_pclk" into "hclk" and "pclk".  Does 
this seem reasonable?

Jamie
