From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] ether1: Use net_device_stats from struct net_device
Date: Tue, 17 Aug 2010 20:32:05 +0200
Message-ID: <20100817183205.GH645@bicker>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56773 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935323Ab0HQScY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 14:32:24 -0400
Content-Disposition: inline
In-Reply-To: <1282061719-19645-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 17, 2010 at 06:15:19PM +0200, Tobias Klauser wrote:
> struct net_device has its own struct net_device_stats member, so use
> this one instead of a private copy in the ether1_priv struct.
> 

You missed one in ether1_open().

        memset (&priv(dev)->stats, 0, sizeof (struct net_device_stats));

regards,
dan carpenter


