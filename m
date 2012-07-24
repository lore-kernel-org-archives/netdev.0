From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: fix NULL pointer check
Date: Tue, 24 Jul 2012 13:57:13 -0700 (PDT)
Message-ID: <20120724.135713.200651049303140450.davem@davemloft.net>
References: <20120724124207.4444.49789.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab2GXU5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 16:57:14 -0400
In-Reply-To: <20120724124207.4444.49789.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 24 Jul 2012 13:42:14 +0100

> From: Alan Cox <alan@linux.intel.com>
> 
> Reported-by: <rucsoftsec@gmail.com>
> Resolves-bug: http://bugzilla.kernel.org/show_bug?44441
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied and queued up for -stable.

> +	if (dev == NULL)

I adjusted this to be "if (!dev)"
