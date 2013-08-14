From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 2/3 v2] ipv6: rename ADBG() to pr_xxx()
Date: Wed, 14 Aug 2013 09:43:47 +0800
Message-ID: <520AE0D3.6000402@huawei.com>
References: <5209E6E8.1030702@huawei.com> <1376412534.1949.33.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:53646 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758874Ab3HNBoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 21:44:18 -0400
In-Reply-To: <1376412534.1949.33.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/8/14 0:48, Joe Perches wrote:
> On Tue, 2013-08-13 at 15:57 +0800, Ding Tianhong wrote:
>> According to Joe Perches opinions, the ADBG() was tedious and it is
>> better to remove the KERN_<LEVEL>s and use the pr_xxx() instead of ADBG().
> 
> No, that's not really what I wrote.
> 
> I suggested it might be better to remove the KERN_<LEVELS>
> from these ADBG uses and use pr_debug.
> 
> As is, you've changed logging messages which today
> always compile away to nothing to now emit what I
> think are pretty unnecessary messages.
> 
> 

sorry for misunderstand your opinion, I will modify it and resend soon.:)

regards
Ding Tianhong

> 
> 
