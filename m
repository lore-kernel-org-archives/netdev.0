From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next 3/4] appletalk: convert printks to pr_<level>
Date: Sat, 15 Feb 2014 09:19:17 +0800
Message-ID: <52FEC095.4080907@huawei.com>
References: <1392363826-8256-1-git-send-email-wangweidong1@huawei.com> <1392363826-8256-4-git-send-email-wangweidong1@huawei.com> <52FE8E91.2040105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<acme@ghostprotocols.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:26978 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbaBOBTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 20:19:38 -0500
In-Reply-To: <52FE8E91.2040105@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/15 5:45, Sergei Shtylyov wrote:
> Hello.
> 
> On 02/14/2014 10:43 AM, Wang Weidong wrote:
> 
>> Prefer pr_<level> then printk(LEVEL).
> 
>> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> 
> [...]
>> diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
>> index 06e0d19..9189d3c 100644
>> --- a/net/appletalk/ddp.c
>> +++ b/net/appletalk/ddp.c
>> @@ -704,9 +704,9 @@ static int atif_ioctl(int cmd, void __user *arg)
>>           if ((dev->flags & IFF_POINTOPOINT) &&
>>               atalk_find_interface(sa->sat_addr.s_net,
>>                        sa->sat_addr.s_node)) {
>> -            printk(KERN_DEBUG "AppleTalk: point-to-point "
>> -                   "interface added with "
>> -                   "existing address\n");
>> +            pr_debug("AppleTalk: point-to-point "
>> +                 "interface added with "
>> +                 "existing address\n");
>>               add_route = 0;
>>           }
>>
> [...]
>> @@ -1329,8 +1328,8 @@ static int atalk_route_packet(struct sk_buff *skb, struct net_device *dev,
>>            * needs to be broadcast onto the default network?
>>            */
>>           if (dev->type == ARPHRD_PPP)
>> -            printk(KERN_DEBUG "AppleTalk: didn't forward broadcast "
>> -                      "packet received from PPP iface\n");
>> +            pr_debug("AppleTalk: didn't forward broadcast "
>> +                 "packet received from PPP iface\n");
> 
>    pr_debug() is not equivalent to printk(KERN_DEBUG). It will only print a message if DEBUG is defined or if dynamic debugging is enabled.
> 
Got it.

WBR, Wang

> WBR, Sergei
> 
> 
> 
