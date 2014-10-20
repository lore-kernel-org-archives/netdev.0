From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ax88179_178a: fix bonding failure
Date: Mon, 20 Oct 2014 00:55:26 -0400 (EDT)
Message-ID: <20141020.005526.1789570582328212500.davem@davemloft.net>
References: <alpine.LFD.2.11.1410190801050.5282@solo.int.primordial.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: imorgan@primordial.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbaJTE5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 00:57:33 -0400
In-Reply-To: <alpine.LFD.2.11.1410190801050.5282@solo.int.primordial.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morgan <imorgan@primordial.ca>
Date: Sun, 19 Oct 2014 08:05:13 -0400 (EDT)

> The following patch fixes a bug which causes the ax88179_178a driver to be
> incapable of being added to a bond.
> 
> When I brought up the issue with the bonding maintainers, they indicated
> that the real problem was with the NIC driver which must return zero for
> success (of setting the MAC address). I see that several other NIC drivers
> follow that pattern by either simply always returing zero, or by passing
> through a negative (error) result while rewriting any positive return code
> to zero. With that same philisophy applied to the ax88179_178a driver, it
> allows it to work correctly with the bonding driver.
> 
> I believe this is suitable for queuing in -stable, as it's a small, simple,
> and obvious fix that corrects a defect with no other known workaround.
> 
> This patch is against vanilla 3.17(.0).
> 
> Signed-off-by: Ian Morgan <imorgan@primordial.ca>

Applied and queued up for -stable, thanks.
