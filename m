From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next 2/6] mac80211: slight optimization of addr
 compare
Date: Mon, 16 Dec 2013 08:47:53 +0100
Message-ID: <1387180073.4665.0.camel@jlt4.sipsolutions.net>
References: <52AEA890.5020305@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:40156 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab3LPHvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 02:51:53 -0500
In-Reply-To: <52AEA890.5020305@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 15:15 +0800, Ding Tianhong wrote:

> -					   sdata->vif.addr, ETH_ALEN) == 0) {
> +				if (ether_addr_equal_unaligned(sdata->vif.addr,
> +				    local->hw.wiphy->addresses[i].addr)) {

Your indentation is terrible, I'm not applying this.

johannes
