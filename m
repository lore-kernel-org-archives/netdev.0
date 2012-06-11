From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rfc net] Allow the autoconfigured network interface to
 be renamed.
Date: Mon, 11 Jun 2012 03:10:53 -0700 (PDT)
Message-ID: <20120611.031053.1433253186495303724.davem@davemloft.net>
References: <1339228087-14870-1-git-send-email-scott@scottnz.com>
	<20120610.202515.138701034400919651.davem@davemloft.net>
	<f8f3fa05ddbe3a2e1613588754f151ac.squirrel@scottnz.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scott.parlane@alliedtelesis.co.nz
To: scott@scottnz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940Ab2FKKK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 06:10:56 -0400
In-Reply-To: <f8f3fa05ddbe3a2e1613588754f151ac.squirrel@scottnz.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: scott@scottnz.com
Date: Mon, 11 Jun 2012 21:58:45 +1200

> They use nfsroot which prevents udev rules from working correctly
> (because you cant take down the interface to rename it)

This is why I hate nfsroot as implemented in the kernel.

Do this right and use an initial ramdisk, then you won't have
this huge disconnect between different device names due to
lack of udev.

Thanks, you've confirmed that this patch is totally inappropriate.
