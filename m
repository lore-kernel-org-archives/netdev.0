From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 2/3 v3] ipv6: convert the uses of ADBG and remove the
 superfluous parentheses
Date: Wed, 14 Aug 2013 11:47:30 +0800
Message-ID: <520AFDD2.1050106@huawei.com>
References: <520AFB20.2000109@huawei.com> <1376451847.1949.60.camel@joe-AO722>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:24465 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759079Ab3HNDss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 23:48:48 -0400
In-Reply-To: <1376451847.1949.60.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/14 11:44, Joe Perches wrote:
> On Wed, 2013-08-14 at 11:36 +0800, Ding Tianhong wrote:
>> Just follow the Joe Perches's opinion, it is a better way to fix the
>> style errors.
> 
> []
> 
>> Signed-off-by: Joe Perches <joe@perches.com>
> 
> Nope, not signed by me.  I sent you a suggestion.
> Please don't add Signed-off-by: signatures for others.
> Maybe you might use Suggested-by:
> 
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> 
>> @@ -99,9 +99,9 @@
>>  #define ACONF_DEBUG 2
>>  
>>  #if ACONF_DEBUG >= 3
>> -#define ADBG(x) printk x
>> +#define ADBG(fmt, ...) printk(fmt, ##__VA_ARGS__)
>>  #else
>> -#define ADBG(x)
>> +#define ADBG(fmt, ...) do {} while (0)
> 
> btw:  The macro I suggested will always verify format
> and arguments.  This will not.
> 
> #define ADBG(fmt, ...) do { if (0) printk(fmt, ##__VA_ARGS__); } while (0)
> 
> 

yes, I got your opinion , but I think it's more simple and clear, maybe not align  :)

> 
> .
> 
