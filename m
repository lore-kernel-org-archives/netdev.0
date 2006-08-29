From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 7/9] sky2: power down PHY when not up
Date: Tue, 29 Aug 2006 14:11:07 -0700
Message-ID: <20060829141107.6d443804@localhost.localdomain>
References: <20060828170044.136391412@localhost.localdomain>
	<20060828170219.598956798@localhost.localdomain>
	<44F4ABFB.1020105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63708 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965391AbWH2VML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 17:12:11 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44F4ABFB.1020105@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006 17:04:59 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> shemminger@osdl.org wrote:
> > To save power, don't enable power to the PHY until device is brought up.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> Strongly agree, and ACK, but note that users have complained in the past 
> when they could not configure their MAC when the interface was down. 
> Users want to eliminate the
> 
> 	ifconfig ethX up
> 	ethtool ...
> 
> race window.
> 
> 	Jeff

This driver should already handle this because the settings are stored
in the device structure and applied when device is brought up.

-- 
Stephen Hemminger <shemminger@osdl.org>
