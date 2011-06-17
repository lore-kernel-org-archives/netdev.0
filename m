From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] ethtool: Add DMA Coalescing adapter feature to
 ethtool.
Date: Thu, 16 Jun 2011 23:32:39 -0400 (EDT)
Message-ID: <20110616.233239.2238723246132860968.davem@davemloft.net>
References: <1308071556-6271-1-git-send-email-carolyn.wyborny@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: carolyn.wyborny@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399Ab1FQDcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:32:43 -0400
In-Reply-To: <1308071556-6271-1-git-send-email-carolyn.wyborny@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>
Date: Tue, 14 Jun 2011 10:12:36 -0700

> This RFC patch adds support for DMA Coalescing device feature
> configuration via ethtool.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
 ...
>  static struct cmdline_info cmdline_offload[] = {
> -	{ "rx", CMDL_BOOL, &off_csum_rx_wanted, NULL },
> -	{ "tx", CMDL_BOOL, &off_csum_tx_wanted, NULL },
> -	{ "sg", CMDL_BOOL, &off_sg_wanted, NULL },

Can you please not destroy the existing formatting of every single
table and piece of code you are modifying?
