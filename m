From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v2] ether1: Use net_device_stats from struct net_device
Date: Wed, 18 Aug 2010 09:13:07 +0100
Message-ID: <20100818081306.GA9149@n2100.arm.linux.org.uk>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch> <1282115064-3701-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org, Dan Carpenter <error27@gmail.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:35978 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab0HRINU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 04:13:20 -0400
Content-Disposition: inline
In-Reply-To: <1282115064-3701-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 18, 2010 at 09:04:24AM +0200, Tobias Klauser wrote:
> @@ -965,7 +965,7 @@ ether1_close (struct net_device *dev)
>  static struct net_device_stats *
>  ether1_getstats (struct net_device *dev)
>  {
> -	return &priv(dev)->stats;
> +	return &dev->stats;
>  }

Doesn't the core do this for you already if you omit this function?

Same comment for ether3.c
