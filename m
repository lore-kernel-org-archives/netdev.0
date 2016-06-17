From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net, cls: also reject deleting all filters
 when TCA_KIND present
Date: Thu, 16 Jun 2016 22:51:03 -0700 (PDT)
Message-ID: <20160616.225103.155583037810168379.davem@davemloft.net>
References: <bbc75e17b5625ef0c41737dcb2b8a5a6faf990d5.1466111210.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbcFQFvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 01:51:04 -0400
In-Reply-To: <bbc75e17b5625ef0c41737dcb2b8a5a6faf990d5.1466111210.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 16 Jun 2016 23:19:29 +0200

> When we check for RTM_DELTFILTER, we should also reject the request
> for deleting all filters under a given parent when TCA_KIND attribute
> is present. If present, it's currently just ignored but there's also
> no point to let it pass in the first place either since this doesn't
> have any meaning with wild-card removal.
> 
> Fixes: ea7f8277f907 ("net, cls: allow for deleting all filters for given parent")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
