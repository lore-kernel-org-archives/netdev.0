From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: Remove superfluous ether_setup after
 alloc_etherdev
Date: Fri, 03 Oct 2014 15:32:22 -0700 (PDT)
Message-ID: <20141003.153222.720360130405710292.davem@davemloft.net>
References: <1412237730-5811-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxime.ripard@free-electrons.com,
	vbridgers2013@gmail.com, nicolas.ferre@atmel.com,
	mcuos.com@gmail.com, nico@fluxnic.net,
	steve.glendinning@shawell.net, peppe.cavallaro@st.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758317AbaJCWaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:30:17 -0400
In-Reply-To: <1412237730-5811-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  2 Oct 2014 10:15:30 +0200

> There is no need to call ether_setup after alloc_ethdev since it was
> already called there.
> 
> Follow commits c706471b2601 ("net: axienet: remove unnecessary
> ether_setup after alloc_etherdev") and 3c87dcbfb36c ("net: ll_temac:
> Remove unnecessary ether_setup after alloc_etherdev") and fix the
> pattern in all remaining ethernet drivers.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
