From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH 1/4] net: smsc911x: add support for a reset GPIO
Date: Tue, 23 Jul 2013 18:44:14 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1307231843480.19465@axis700.grange>
References: <1374595924-12338-1-git-send-email-g.liakhovetski@gmx.de>
 <1374595924-12338-2-git-send-email-g.liakhovetski@gmx.de>
 <CAOMZO5AzEgkyRz0N0a3CSS7sWEatT3ZQX9eku1fH6hzheh0ARA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:55948 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168Ab3GWQoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 12:44:17 -0400
In-Reply-To: <CAOMZO5AzEgkyRz0N0a3CSS7sWEatT3ZQX9eku1fH6hzheh0ARA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Jul 2013, Fabio Estevam wrote:

> On Tue, Jul 23, 2013 at 1:12 PM, Guennadi Liakhovetski
> <g.liakhovetski@gmx.de> wrote:
> 
> > +       if (pdata->config.reset_gpio_config & SMSC911X_RESET_GPIO_VALID) {
> > +               /* Take the chip out of hard reset */
> > +               unsigned long flags = (pdata->config.reset_gpio_config ^
> > +                                      GPIOF_INIT_HIGH) & 0xf;
> > +               retval = gpio_request_one(pdata->config.reset_gpio,
> 
> If you use devm_gpio_request_one() here, then you can simplify your
> code by not having to call gpio_free.

Oops, sure, will update, thanks.

Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
