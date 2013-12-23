From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 19/21] wireless: slight optimization of addr compare
Date: Mon, 23 Dec 2013 14:47:13 +0100
Message-ID: <52B83EE1.4040705@openwrt.org>
References: <52B7C600.8030907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52B7C600.8030907@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013-12-23 06:11, Ding Tianhong wrote:
> Use the recently added and possibly more efficient
> ether_addr_equal_unaligned to instead of memcmp.
It looks to me like all of these (including the ones in the other
similar patches) are in places, where the address data is aligned to at
least 16 bit. Because of this, using ether_addr_equal instead of
ether_addr_equal_unaligned would be much better for platforms without
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.

- Felix
