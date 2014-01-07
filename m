From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v3.5 10/19] mac8011: slight optimization of addr compare
Date: Tue, 7 Jan 2014 11:40:38 +0800
Message-ID: <52CB7736.701@huawei.com>
References: <52BC15C8.2080400@huawei.com> <1389021111.5891.21.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389021111.5891.21.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/1/6 23:11, Johannes Berg wrote:
> On Thu, 2013-12-26 at 19:40 +0800, Ding Tianhong wrote:
>> Use the possibly more efficient ether_addr_equal
>> to instead of memcmp.
> 
> This is a slow-path, I don't think that's really worth it. It kinda
> makes sense, but relies on the struct mac_address allocation for
> alignment and the fact that there are no other members in that struct,
> so it seems to me that this ought to also add some alignment attributes?
> 
> johannes
> 
> 

Yes, I had to say that it is really a slight optimization.And I am sure the address in the struct
is alignment, otherwise I have to use the ether_addr_equal_unaligned().

Regards
Ding 

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
