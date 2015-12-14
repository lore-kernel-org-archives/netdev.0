From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] ravb: clear RIC1 in init instead of stop
Date: Mon, 14 Dec 2015 14:33:24 -0500 (EST)
Message-ID: <20151214.143324.2191268209263094341.davem@davemloft.net>
References: <1450110298-21392-1-git-send-email-ykaneko0929@gmail.com>
	<566EF503.10304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ykaneko0929@gmail.com, netdev@vger.kernel.org, horms@verge.net.au,
	magnus.damm@gmail.com, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <566EF503.10304@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 14 Dec 2015 19:57:39 +0300

> On 12/14/2015 07:24 PM, Yoshihiro Kaneko wrote:
> 
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> AVB-DMAC Receive FIFO Warning interrupt is not enabled, so it is not
>> necessary to disable the interrupt in ravb_close().
>> On the other hand, this patch disables the interrupt in
>> ravb_dmac_init() to
>> prevent the possibility that the interrupt is issued by the state that
>> a boot loader left.
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> 
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
>> ---
>>
>> This patch is based on the master branch of David Miller's networking
>> tree.
> 
>    I think this should rather go into net-next.git though...

Agreed, applied to net-next, thanks.
