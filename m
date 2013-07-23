From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH] 8139cp: Add dma_mapping_error checking
Date: Tue, 23 Jul 2013 09:00:36 -0400
Message-ID: <20130723130035.GA6759@hmsreliant.think-freely.org>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
 <20130722214839.GB4997@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35238 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599Ab3GWNA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 09:00:57 -0400
Content-Disposition: inline
In-Reply-To: <20130722214839.GB4997@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 11:48:39PM +0200, Francois Romieu wrote:
> Neil Horman <nhorman@tuxdriver.com> :
> [...]
> > failed.  Untested as I have no hardware and the reporter has wandered off, but
> > seems pretty straightforward.
> 
> It does not update dev->stats.tx_dropped in the xmit path.
> 
Thanks, missed that, I'll respin
Neil

> -- 
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
