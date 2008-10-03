From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/6] [NET] dsa: add support for original DSA tagging
 format
Date: Fri, 3 Oct 2008 19:36:01 +0200
Message-ID: <20081003193601.4f7fbe42@speedy>
References: <20080929023829.GI21560@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34409 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753195AbYJCRgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2008 13:36:10 -0400
In-Reply-To: <20080929023829.GI21560@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please use stronger types..

> +static inline int netdev_uses_dsa_tags(struct net_device *dev)

I would use:
static inline bool netdev_uses_dsa_tags(const struct net_device *dev)


> +int dsa_uses_dsa_tags(void *dsa_ptr);
extern bool dsa_uses_dsa_tags(const struct dsa_switch *dsa);

