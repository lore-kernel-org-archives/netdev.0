From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 13/21] mac8011: slight optimization of addr compare
Date: Mon, 06 Jan 2014 16:21:17 +0100
Message-ID: <1389021677.5891.28.camel@jlt4.sipsolutions.net>
References: <52B7C5DA.9090307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B7C5DA.9090307@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-23 at 13:10 +0800, Ding Tianhong wrote:
> Use the recently added and possibly more efficient
> ether_addr_equal_unaligned to instead of memcmp.

> -				if (memcmp(local->hw.wiphy->addresses[i].addr,
> -					   sdata->vif.addr, ETH_ALEN) == 0) {
> +				if (ether_addr_equal_unaligned(local->hw.wiphy->addresses[i].addr, sdata->vif.addr)) {

This clearly should have some linebreaks.

This code also doesn't care all that much about efficiency, so not sure
it's worth it at all.

johannes
