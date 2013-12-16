From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 2/6] mac80211: slight optimization of addr compare
Date: Mon, 16 Dec 2013 16:04:27 +0800
Message-ID: <52AEB40B.4050308@huawei.com>
References: <52AEA890.5020305@huawei.com> <1387180073.4665.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:43749 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab3LPIFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:05:09 -0500
In-Reply-To: <1387180073.4665.0.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/16 15:47, Johannes Berg wrote:
> On Mon, 2013-12-16 at 15:15 +0800, Ding Tianhong wrote:
> 
>> -					   sdata->vif.addr, ETH_ALEN) == 0) {
>> +				if (ether_addr_equal_unaligned(sdata->vif.addr,
>> +				    local->hw.wiphy->addresses[i].addr)) {
> 
> Your indentation is terrible, I'm not applying this.
> 
> johannes
> 

ok, I'll fix it.

Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
