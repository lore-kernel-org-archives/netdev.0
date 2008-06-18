From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netdevice: change net_device->promiscuity/allmulti
 to unsigned int
Date: Tue, 17 Jun 2008 21:12:58 -0700 (PDT)
Message-ID: <20080617.211258.91148544.davem@davemloft.net>
References: <48562F0D.1090107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750861AbYFREM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 00:12:57 -0400
In-Reply-To: <48562F0D.1090107@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 16 Jun 2008 17:14:53 +0800

> The comments of dev_set_allmulti/promiscuity() is that "While the count in
> the device remains above zero...". So negative count is useless.
> Fix the type of the counter from "int" to "unsigned int".
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied to net-next-2.6, thanks!
