From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 08/50] bnx2x: use dev_hw_addr_random() instead of random_ether_addr()
Date: Thu, 9 Feb 2012 09:59:35 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E5F@saturn3.aculab.com>
References: <1328735457-29986-9-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Danny Kukawka" <dkukawka@suse.de>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Danny Kukawka" <danny.kukawka@bisect.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1328735457-29986-9-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> +	if (dev->addr_assign_type & NET_ADDR_RANDOM)
> +		dev->addr_assign_type ^= NET_ADDR_RANDOM;

Why not just:
	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
the cache is probably dirty and it won't be a critical path.

	David
