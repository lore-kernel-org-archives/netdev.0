From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: New build error - ndo_set_mac_addr
Date: Wed, 14 Jan 2009 12:06:20 -0800
Message-ID: <20090114120620.13cf8039@extreme>
References: <20090114194746.GL22976@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51904 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219AbZANUGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 15:06:23 -0500
In-Reply-To: <20090114194746.GL22976@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2009 19:47:46 +0000
Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> This new build error poped up between rc1-git2 and rc1-git3.
> 
> drivers/net/arm/etherh.c:649: error: unknown field 'ndo_set_mac_addr' specified in initializer
> 
> Looks like this should've been ndo_set_mac_address ?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Yes, david didn't see the updated version of my patch.
