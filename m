From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] ether3: Use net_device_stats from struct net_device
Date: Tue, 17 Aug 2010 20:35:52 +0200
Message-ID: <20100817183551.GI645@bicker>
References: <1282061733-19700-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40391 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934266Ab0HQSgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 14:36:10 -0400
Content-Disposition: inline
In-Reply-To: <1282061733-19700-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 17, 2010 at 06:15:33PM +0200, Tobias Klauser wrote:
> struct net_device has its own struct net_device_stats member, so use
> this one instead of a private copy in the ether1_priv struct.
> 

Two were missed, one from ether3_init_for_open()

	memset(&priv(dev)->stats, 0, sizeof(struct net_device_stats));

and another from ether3_rx().

	struct net_device_stats *stats = &priv(dev)->stats;

regards,
dan carpenter


