From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: kconfig: move mmap i/o into netlink kconfig
Date: Wed, 01 May 2013 15:03:12 -0400 (EDT)
Message-ID: <20130501.150312.313536267350830908.davem@davemloft.net>
References: <1367408240-30320-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919Ab3EATDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:03:14 -0400
In-Reply-To: <1367408240-30320-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  1 May 2013 13:37:20 +0200

> Currently, in menuconfig, Netlink's new mmaped IO is the very first
> entry under the ``Networking support'' item and comes even before
> ``Networking options'':
> 
>   [ ]   Netlink: mmaped IO
>   Networking options  --->
>   ...
> 
> Lets move this into ``Networking options'' under netlink's Kconfig,
> since this might be more appropriate. Introduced by commit ccdfcc398
> (``netlink: mmaped netlink: ring setup'').
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks for fixing this up Daniel.
