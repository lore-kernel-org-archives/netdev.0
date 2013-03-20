From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Define indexes as 'unsigned int'
Date: Wed, 20 Mar 2013 12:29:19 -0400 (EDT)
Message-ID: <20130320.122919.243344177153660068.davem@davemloft.net>
References: <1363793467-18860-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab3CTQ3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 12:29:22 -0400
In-Reply-To: <1363793467-18860-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Wed, 20 Mar 2013 12:31:07 -0300

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Fix the following warnings that happen when building with W=1 option:
> 
> drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_free_buffers':
> drivers/net/ethernet/freescale/fec.c:1337:16: warning: comparison between signed and unsigned integer expressions [-Wsign-compare]
> drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_alloc_buffers':
> drivers/net/ethernet/freescale/fec.c:1361:16: warning: comparison between signed and unsigned integer expressions [-Wsign-compare]
> drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_init':
> drivers/net/ethernet/freescale/fec.c:1631:16: warning: comparison between signed and unsigned integer expressions [-Wsign-compare]
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied, thanks.
