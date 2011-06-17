From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: bfin_mac: fix memory leak when freeing dma
 descriptors
Date: Fri, 17 Jun 2011 00:19:23 -0400 (EDT)
Message-ID: <20110617.001923.669995601708921476.davem@davemloft.net>
References: <1308263518-22724-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56329 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444Ab1FQETl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:19:41 -0400
In-Reply-To: <1308263518-22724-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Thu, 16 Jun 2011 18:31:58 -0400

> From: Sonic Zhang <sonic.zhang@analog.com>
> 
> The size of the desc array is not the size of the desc structure, so
> when we try to free up things, we leak some parts.
> 
> Reported-by: Regis Dargent <rdargent@edevice.com>
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied, thanks.
