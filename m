From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3 02/07] r8169: Support for byte queue limits
Date: Mon, 21 Oct 2013 10:55:31 +0100
Message-ID: <1382349331.25689.15.camel@deadeye.wl.decadent.org.uk>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
	 <1382296991-20289-3-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Igor Maravic <igorm@etf.rs>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Tino Reichardt <milky-kernel@mcmilk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64890 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059Ab3JUJzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:55:36 -0400
In-Reply-To: <1382296991-20289-3-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-10-20 at 21:23 +0200, Tino Reichardt wrote:
> Changes to r8169 driver to use byte queue limits.
[...]
> +		if (unlikely(bql_disable))
> +			netdev_completed_queue(dev, pkts_compl, bytes_compl);
>  		if (netif_queue_stopped(dev) &&
>  		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
>  			netif_wake_queue(dev);

This is obviously wrong.  Please limit your changes to drivers you can
actually test.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
