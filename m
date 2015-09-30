From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Add support for filtering neigh dump
 by master device
Date: Tue, 29 Sep 2015 21:34:08 -0700 (PDT)
Message-ID: <20150929.213408.719303089005272145.davem@davemloft.net>
References: <1443544323-13242-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbbI3EeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:34:09 -0400
In-Reply-To: <1443544323-13242-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 29 Sep 2015 09:32:03 -0700

> Add support for filtering neighbor dumps by master device by adding
> the NDA_MASTER attribute to the dump request. A new netlink flag,
> NLM_F_DUMP_FILTERED, is added to indicate the kernel supports the
> request and output is filtered as requested.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - added NLM_F_DUMP_FILTERED flag for userspace feedback that request is
>   supported
> 
> This method works for other filters as well and other dump commands.
> Works fine for all combinations of new and old kernel and new and old ip:
> 1. new ip command on old kernel, NDA_MASTER attribute is ignored
> 2. old ip command on new kernel, NDA_MASTER attribute is not present
> 3. new ip on new kernel ... goodness ensues by limiting data to
>    only what user wants

Applied, thanks.
