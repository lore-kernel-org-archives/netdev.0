From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ems_usb: cleanup: remove uneeded check
Date: Sun, 07 Mar 2010 15:28:05 -0800 (PST)
Message-ID: <20100307.152805.244203159.davem@davemloft.net>
References: <20100306111138.GH4958@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	wg@grandegger.com, haas@ems-wuensche.com, kurt.van.dijck@eia.be,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751063Ab0CGX1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 18:27:45 -0500
In-Reply-To: <20100306111138.GH4958@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 6 Mar 2010 14:11:38 +0300

> "skb" is alway non-null here, but even if it were null the check isn't
> needed because dev_kfree_skb() can handle it.
> 
> This eliminates a smatch warning about dereferencing a variable before
> checking that it is non-null.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
