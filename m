From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] ether1: Use net_device_stats from struct net_device
Date: Tue, 17 Aug 2010 20:34:09 +0200
Message-ID: <20100817183409.GF15670@distanz.ch>
References: <1282061719-19645-1-git-send-email-tklauser@distanz.ch> <20100817183205.GH645@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:57422 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935876Ab0HQSeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 14:34:11 -0400
Content-Disposition: inline
In-Reply-To: <20100817183205.GH645@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-08-17 at 20:32:05 +0200, Dan Carpenter <error27@gmail.com> wrote:
> On Tue, Aug 17, 2010 at 06:15:19PM +0200, Tobias Klauser wrote:
> > struct net_device has its own struct net_device_stats member, so use
> > this one instead of a private copy in the ether1_priv struct.
> > 
> 
> You missed one in ether1_open().
> 
>         memset (&priv(dev)->stats, 0, sizeof (struct net_device_stats));

Thanks. I'll send an updated patch.

Tobias
