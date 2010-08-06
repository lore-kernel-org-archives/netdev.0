From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH] net: add Fast Ethernet driver for PXA168.
Date: Fri, 06 Aug 2010 10:02:32 -0700
Message-ID: <1281114152.17033.43.camel@Joe-Laptop.home>
References: <EC64E4604C8024438259B683BB2514E1082B1CB20F@SC-VEXCH1.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Philip Rakity <prakity@marvell.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Prabhanjan Sarnaik <sarnaik@marvell.com>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	Mark Brown <markb@marvell.com>
To: Sachin Sanap <ssanap@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2318 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759310Ab0HFRCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 13:02:36 -0400
In-Reply-To: <EC64E4604C8024438259B683BB2514E1082B1CB20F@SC-VEXCH1.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-08-06 at 09:55 -0700, Sachin Sanap wrote:
> > >>> +		skb = dev_alloc_skb(MAX_PKT_SIZE + ETH_HW_IP_ALIGN);
> > >>> skb = dev_alloc_skb(MAX_PKT_SIZE + ETH_HW_IP_ALIGN + EXTRA_PREPEND_SPACE);

You could also use:
	skb = netdev_alloc_skb_ip_align(dev, MAX_PKT_SIZE + EXTRA_PREPEND_SPACE)

