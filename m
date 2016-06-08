From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: fix missing <linux/of_net.h>
Date: Wed, 08 Jun 2016 00:38:21 -0700 (PDT)
Message-ID: <20160608.003821.2052356443958850976.davem@davemloft.net>
References: <1465324071-7337-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org
To: ben.dooks@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbcFHHiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 03:38:22 -0400
In-Reply-To: <1465324071-7337-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben.dooks@codethink.co.uk>
Date: Tue,  7 Jun 2016 19:27:51 +0100

> The of_find_net_device_by_node() function is defined in
> <linux/of_net.h> but not included in the .c file that
> implements it. Fix the following warning by including the
> header:
> 
> net/core/net-sysfs.c:1494:19: warning: symbol 'of_find_net_device_by_node' was not declared. Should it be static?
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>

Applied, thanks.
