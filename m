From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] dp83640: Fix NOHZ local_softirq_pending 08 warning
Date: Thu, 12 Jan 2012 11:51:02 -0800
Message-ID: <20120112195102.GA28100@kroah.com>
References: <1326369485-6218-1-git-send-email-manfred.rudigier@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stable@vger.kernel.org, richardcochran@gmail.com
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55052 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753848Ab2ALUAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 15:00:11 -0500
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 8674623DDC
	for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 15:00:10 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <1326369485-6218-1-git-send-email-manfred.rudigier@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2012 at 12:58:05PM +0100, Manfred Rudigier wrote:
> Similar problem as in 481a8199142c050b72bff8a1956a49fd0a75bbe0. This fix
> replaces netif_rx() with netif_rx_ni() which has to be used from
> process/softirq context.
> 
> Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
> ---
>  drivers/net/phy/dp83640.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
