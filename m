From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC(v2) net-next 12/13] ipv6: Remove temporary dst for icmpv6.
Date: Wed, 16 Jan 2013 23:26:27 +0900
Message-ID: <50F6B893.2030206@linux-ipv6.org>
References: <50F587E8.1060308@linux-ipv6.org> <50F6507B.5030908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42679 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755686Ab3APO02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 09:26:28 -0500
In-Reply-To: <50F6507B.5030908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> On 01/16/2013 12:46 AM, YOSHIFUJI Hideaki wrote:
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> ---
>>   net/ipv6/ip6_fib.c |    2 +-
>>   net/ipv6/route.c   |   98 ----------------------------------------------------
>>   2 files changed, 1 insertion(+), 99 deletions(-)
> [...]
>> -
>> -int icmp6_dst_gc(void)
>> -{
> 
> Please remove its declaration too:
> include/net/ip6_route.h:extern int icmp6_dst_gc(void);

Agreed.  Also removed icmp6_dst_alloc().

--yoshfuji
