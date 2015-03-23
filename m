From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sfc fixup patch
Date: Mon, 23 Mar 2015 22:05:54 +1100
Message-ID: <1427108754.4770.228.camel@kernel.crashing.org>
References: <1427080232.4770.212.camel@kernel.crashing.org>
	 <550FF113.8000209@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40749 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964AbbCWLWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 07:22:40 -0400
In-Reply-To: <550FF113.8000209@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-23 at 10:55 +0000, Shradha Shah wrote:

> > net/ethernet/sfc: Don't use of_node_to_eeh_dev()
> >
> > This is deprecated, it forces the driver to hop via the OF node
> > that may or may not exist, instead use pci_dev_to_eeh_dev() which
> > is simpler.
> >
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
> Acked-by: Shradha Shah <sshah@solarflare.com>

Thanks !

Cheers,
Ben.
