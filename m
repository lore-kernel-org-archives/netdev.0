From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sh_eth: fix bitbang memory leak
Date: Wed, 20 Mar 2013 12:23:46 -0400 (EDT)
Message-ID: <20130320.122346.949755604432580585.davem@davemloft.net>
References: <201303200240.23975.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758047Ab3CTQXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:23:48 -0400
In-Reply-To: <201303200240.23975.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 20 Mar 2013 02:40:23 +0300

> sh_mdio_init() allocates pointer to 'struct bb_info' but only stores it locally,
> so that sh_mdio_release() can't free it on driver unload.  Add the pointer to
> 'struct bb_info' to 'struct sh_eth_private', so that sh_mdio_init() can save
> 'bitbang' variable for sh_mdio_release() to be able to free it later...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied and queued up for -stable.
