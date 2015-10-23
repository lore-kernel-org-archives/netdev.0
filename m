From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sysctl: fix a kmemleak warning
Date: Fri, 23 Oct 2015 03:04:44 -0700 (PDT)
Message-ID: <20151023.030444.704308961251594308.davem@davemloft.net>
References: <1445484432-17673-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbbJWJsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:48:14 -0400
In-Reply-To: <1445484432-17673-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Thu, 22 Oct 2015 11:27:12 +0800

> +out1:
> +	unregister_sysctl_table(net_header);
> +	kfree(net_header);

I read over unregister_sysctl_table() and it appears to do the kfree()
for us, doesn't it?
