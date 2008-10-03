From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/6] [NET] dsa: add support for original DSA tagging format
Date: Fri, 3 Oct 2008 21:47:20 +0200
Message-ID: <20081003194720.GB15924@xi.wantstofly.org>
References: <20080929023829.GI21560@xi.wantstofly.org> <20081003193601.4f7fbe42@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:60827 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbYJCTrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 15:47:21 -0400
Content-Disposition: inline
In-Reply-To: <20081003193601.4f7fbe42@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 03, 2008 at 07:36:01PM +0200, Stephen Hemminger wrote:

> Please use stronger types..
> 
> > +static inline int netdev_uses_dsa_tags(struct net_device *dev)
> 
> I would use:
> static inline bool netdev_uses_dsa_tags(const struct net_device *dev)
> 
> 
> > +int dsa_uses_dsa_tags(void *dsa_ptr);
> extern bool dsa_uses_dsa_tags(const struct dsa_switch *dsa);

OK.  Did the same thing for the trailer tag support.
