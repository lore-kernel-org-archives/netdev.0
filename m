From: David Miller <davem@davemloft.net>
Subject: Re: [patch] mISDN: fix a loop count
Date: Tue, 15 Dec 2015 12:51:33 -0500 (EST)
Message-ID: <20151215.125133.1380311053547267182.davem@davemloft.net>
References: <20151215100752.GC20848@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, arnd@arndb.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48043 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028AbbLORvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:51:35 -0500
In-Reply-To: <20151215100752.GC20848@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 13:07:52 +0300

> There are two issue here.
> 1)  cnt starts as maxloop + 1 so all these loops iterate one more time
>     than intended.
> 2)  At the end of the loop we test for "if (maxloop && !cnt)" but for
>     the first two loops, we end with cnt equal to -1.  Changing this to
>     a pre-op means we end with cnt set to 0.
> 
> Fixes: cae86d4a4e56 ('mISDN: Add driver for Infineon ISDN chipset family')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
