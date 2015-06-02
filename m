From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg
 and sendmsg
Date: Mon, 01 Jun 2015 22:23:57 -0700 (PDT)
Message-ID: <20150601.222357.122000161676177828.davem@davemloft.net>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
	<20150602012154.GB23370@kroah.com>
	<556D2B8C.9010108@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, lizefan@huawei.com,
	viro@zeniv.linux.org.uk, xuhanbing@huawei.com,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: zhengjunling@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748AbbFBFX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 01:23:59 -0400
In-Reply-To: <556D2B8C.9010108@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junling Zheng <zhengjunling@huawei.com>
Date: Tue, 2 Jun 2015 12:05:32 +0800

> So, the problem commit is 281c9c36 (net: compat: Update
> get_compat_msghdr() to match copy_msghdr_from_user() behaviour),
> which fixes db31c55a6fb2 and brings the get_compat_msghdr() in line
> with copy_msghdr_from_user().

Upstream this got fixed by:

08adb7dabd4874cc5666b4490653b26534702ce0

So the part that makes us not unconditionally return -EFAULT needs
to be backported, and that's probably equivalent to the patch
your proposed which therefore should be applied.
