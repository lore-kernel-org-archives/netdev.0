From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] netlink: switch net_ns only if net is not init_net
Date: Mon, 10 Mar 2014 09:11:24 +0800
Message-ID: <531D113C.80709@cn.fujitsu.com>
References: <5319A3C2.8080001@cn.fujitsu.com> <20140309.190941.472588800498066811.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140309.190941.472588800498066811.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2014 07:09 AM, David Miller wrote:

> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
> Date: Fri, 07 Mar 2014 18:47:30 +0800
> 
>> Many netlink users create netlink sock in the init_net, and the
>> switching nes_ns(init_net-->net) is needless in this case. So here
>> we add a pre-check to avoid this.
>>
>> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> 
> This check is more appropriately placed into sk_change_net() itself.

Agree. I'll update it soon.

Regards,
Gu

> 
