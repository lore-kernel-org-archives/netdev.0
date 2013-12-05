From: Wang Weidong <wangweidong1@huawei.com>
Subject: Re: [PATCH] x25: convert printks to pr_<level>
Date: Thu, 5 Dec 2013 12:19:00 +0800
Message-ID: <529FFEB4.2030908@huawei.com>
References: <529FEDBC.9030302@huawei.com> <1386216573.30493.86.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <andrew.hendry@gmail.com>,
	<linux-x25@vger.kernel.org>, <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:59080 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab3LEETt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 23:19:49 -0500
In-Reply-To: <1386216573.30493.86.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/5 12:09, Joe Perches wrote:
> On Thu, 2013-12-05 at 11:06 +0800, Wang Weidong wrote:
>> use pr_<level> instead of printk(LEVEL)
> 
> Consider adding
> #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> or
> #define pr_fmt(fmt) "X25: " fmt
> to each of these files before any #include
> and removing the leading "X25: " in each of
> the formats.
> 

Thanks for your suggestions. I will fix it in v2.

Regards.

> 
> 
> 
> 
