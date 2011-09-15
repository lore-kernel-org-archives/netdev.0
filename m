From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: don't clear IFF_XMIT_DST_RELEASE in ether_setup
Date: Thu, 15 Sep 2011 15:08:36 -0400 (EDT)
Message-ID: <20110915.150836.36536915642949050.davem@davemloft.net>
References: <1316005502-7341-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934458Ab1IOTJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 15:09:43 -0400
In-Reply-To: <1316005502-7341-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 14 Sep 2011 09:05:02 -0400

> d88733150 introduced the IFF_SKB_TX_SHARING flag, which I unilaterally set in
> ether_setup.  In doing this I didn't realize that other flags (such as
> IFF_XMIT_DST_RELEASE) might be set prior to calling the ether_setup routine.
> This patch changes ether_setup to or in SKB_TX_SHARING so as not to
> inadvertently clear other existing flags.  Thanks to Pekka Riikonen for pointing
> out my error
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Pekka Riikonen <priikone@iki.fi>

Applied, thanks Neil.
