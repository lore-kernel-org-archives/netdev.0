From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 2/2] ipv6: fix checkpatch errors in net/ipv6/addrconf.c
Date: Tue, 13 Aug 2013 14:54:21 +0800
Message-ID: <5209D81D.1070702@huawei.com>
References: <5209CEEC.2050505@huawei.com> <1376375456.1949.22.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:1589 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322Ab3HMGzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 02:55:04 -0400
In-Reply-To: <1376375456.1949.22.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/13 14:30, Joe Perches wrote:
> On Tue, 2013-08-13 at 14:15 +0800, Ding Tianhong wrote:
>> ERROR: Macros with complex values should be enclosed in parenthesis
>> +#define ADBG(x) printk x
> []
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> []
>> @@ -99,7 +99,7 @@
> []
>> -#define ADBG(x) printk x
>> +#define ADBG(x) (printk x)
> 
> A better way to fix this would be
> to convert the uses of ADBG and remove
> the superfluous parentheses.
> 
> Something like the below but it might
> even better to remove the KERN_<LEVEL>s and
> just use pr_debug instead of ADBG...
> ---

thanks for your opinion. I think it's time to remove the tedious code and replace with pr_debug and pr_warning, I will send v2 to fix it.
