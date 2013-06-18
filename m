From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] net, scsi/csgb4i: convert
 skb->transport_header into skb_transport_header(skb)
Date: Mon, 17 Jun 2013 17:13:14 -0700 (PDT)
Message-ID: <20130617.171314.1432482611027368309.davem@davemloft.net>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
	<7ae8c4225b5d19a2ad7d621bc7e08a74b1b4583e.1371200138.git.yamahata@valinux.co.jp>
	<20130617020411.GF15043@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yamahata@valinux.co.jp, netdev@vger.kernel.org,
	roy.qing.li@gmail.com, linux-scsi@vger.kernel.org
To: horms@verge.net.au
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20130617020411.GF15043@verge.net.au>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Mon, 17 Jun 2013 11:04:11 +0900

> On Fri, Jun 14, 2013 at 05:58:32PM +0900, Isaku Yamahata wrote:
>> The change set of 1a37e412, "net: Use 16bits for *_headers fields
>> of struct skbuff" converted from sk_buff_data_t into 16bit integer.
>> So skb->tail needs to be converted to skb_tail_pointer(skb).
>> 
>> Found by inspection. Compile tested only.
>> 
>> Cc: Simon Horman <horms@verge.net.au>
>> Cc: Li RongQing <roy.qing.li@gmail.com>
>> Cc: linux-scsi@vger.kernel.org
>> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied.
