From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iMX28 Ethernet driver fix
Date: Wed, 09 Nov 2011 16:11:34 -0500 (EST)
Message-ID: <20111109.161134.468360904095628089.davem@davemloft.net>
References: <20111109124411.GA31046@axolotl.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: phorton@bitbox.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933093Ab1KIVNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 16:13:49 -0500
In-Reply-To: <20111109124411.GA31046@axolotl.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Horton <phorton@bitbox.co.uk>
Date: Wed, 9 Nov 2011 12:44:11 +0000

> -	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
> +	if ((((unsigned long) bufaddr) & FEC_ALIGNMENT) ||
> +		((id_entry->driver_data & FEC_QUIRK_SWAP_FRAME) &&
> +		skb_cloned(skb)))
> +	{

Please format this condition properly:

	if (A ||
	    (B &&
             C)) {
