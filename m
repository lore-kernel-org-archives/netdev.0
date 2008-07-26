From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH] 3c59x: use netdev_alloc_skb
Date: Sat, 26 Jul 2008 20:55:47 +0200
Message-ID: <20080726185547.GA26670@bayes.mathematik.tu-chemnitz.de>
References: <20080725120722.1f2668a1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lana.hrz.tu-chemnitz.de ([134.109.132.3]:50243 "EHLO
	lana.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbYGZSzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 14:55:49 -0400
Content-Disposition: inline
In-Reply-To: <20080725120722.1f2668a1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 12:07:22PM -0700, Stephen Hemminger wrote:
> Fix possible bug where end of receive buffer could be overwritten.
> The allocation needs to allow for the reserved space. This would only happen
> if device received packet greater than Ethernet standard MTU.
> 
> Change this driver to use netdev_alloc_skb rather than setting skb->dev
> directly. For the initial allocation it doesn't need to be GFP_ATOMIC.
> 
> Compile tested only.
> 
Looks good.

I'll give it a try as soon as I'm back from OLS next week.

Thanks,

Steffen
