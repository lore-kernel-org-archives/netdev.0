From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] Backport to stable-3.4 for fix CVE-2014-0181
Date: Thu, 24 Jul 2014 16:06:13 -0700 (PDT)
Message-ID: <20140724.160613.1238251785577893186.davem@davemloft.net>
References: <1405650086-58596-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangyufen@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755965AbaGXXGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 19:06:16 -0400
In-Reply-To: <1405650086-58596-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wangyufen <wangyufen@huawei.com>
Date: Fri, 18 Jul 2014 10:21:19 +0800

> This backport fix CVE-2014-0181 which would still be vulnerable in
> stable-3.4, please add it.
> 
> patchset from 5187cd055b6e to 90f62cf30a78 fixed CVE-2014-0181,
> which can't backport to stable-3.4 directly, 
> 
> Those three patches are needed:
> commit 935d8aabd4331f47a89c3e1daa5779d23cf244ee 
> commit 038e7332b8d4c0629a2965e3ede1a92e8e427bd6
> commit 3fbc290540a1ed1a8a076ed8f53bee7a38a9f408 
> 
> and this patch is unneeded:
> commit a53b72c83a4216f2eb883ed45a0cbce014b8e62d

Unfortunately this backport has two very serious problems.

1) The From: is set to you for each patch, but you are not the author
   of these patches.  Most of them are written by Eric Biederman and
   one is written by Linus Torvalds.

   Having to do some backporting when putting together some -stable
   submissions does not mean you can just usurp authorship from the
   person who wrote the original change.

2) You failed to include the patch:

	commit 2d7a85f4b06e9c27ff629f07a524c48074f07f81
	Author: Eric W. Biederman <ebiederm@xmission.com>
	Date:   Fri May 30 11:04:00 2014 -0700

	    netlink: Only check file credentials for implicit destinations

   which fixes this series to not break applications like Zebra.
