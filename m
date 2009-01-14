From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: New build error - ndo_set_mac_addr
Date: Wed, 14 Jan 2009 20:19:07 +0000
Message-ID: <20090114201907.GA2162@n2100.arm.linux.org.uk>
References: <20090114194746.GL22976@n2100.arm.linux.org.uk> <20090114120620.13cf8039@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54213 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbZANUTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 15:19:17 -0500
Content-Disposition: inline
In-Reply-To: <20090114120620.13cf8039@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 12:06:20PM -0800, Stephen Hemminger wrote:
> On Wed, 14 Jan 2009 19:47:46 +0000
> Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> 
> > This new build error poped up between rc1-git2 and rc1-git3.
> > 
> > drivers/net/arm/etherh.c:649: error: unknown field 'ndo_set_mac_addr' specified in initializer
> > 
> > Looks like this should've been ndo_set_mac_address ?
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Yes, david didn't see the updated version of my patch.

Do you want me to fix it?  It'll probably be around a week before I ask
Linus to pull my tree again.
