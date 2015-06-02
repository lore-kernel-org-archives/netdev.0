From: Junling Zheng <zhengjunling@huawei.com>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg
 and sendmsg
Date: Tue, 2 Jun 2015 14:33:51 +0800
Message-ID: <556D4E4F.5090609@huawei.com>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>	<20150602012154.GB23370@kroah.com>	<556D2B8C.9010108@huawei.com> <20150601.222357.122000161676177828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, <lizefan@huawei.com>,
	<viro@zeniv.linux.org.uk>, <xuhanbing@huawei.com>,
	<stable@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:14439 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbbFBGe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 02:34:27 -0400
In-Reply-To: <20150601.222357.122000161676177828.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/6/2 13:23, David Miller wrote:
> From: Junling Zheng <zhengjunling@huawei.com>
> Date: Tue, 2 Jun 2015 12:05:32 +0800
> 
>> So, the problem commit is 281c9c36 (net: compat: Update
>> get_compat_msghdr() to match copy_msghdr_from_user() behaviour),
>> which fixes db31c55a6fb2 and brings the get_compat_msghdr() in line
>> with copy_msghdr_from_user().
> 
> Upstream this got fixed by:
> 
> 08adb7dabd4874cc5666b4490653b26534702ce0
> 
> So the part that makes us not unconditionally return -EFAULT needs
> to be backported, and that's probably equivalent to the patch
> your proposed which therefore should be applied.
> 
> .
> 
Yes, we indeed missed some changes of 08adb7d, and these changes could
make commit 281c9c36 appropriate for stable version.
In addition, I think other stable version also needs this fix.

Cheers,

Junling
