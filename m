From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] skge: fix build on 32 bit
Date: Sun, 04 Aug 2013 23:37:03 -0700 (PDT)
Message-ID: <20130804.233703.1168996503704421393.davem@davemloft.net>
References: <20130804172234.345913ae@nehalam.linuxnetplumber.net>
	<20130804.183553.514470399074672614.davem@davemloft.net>
	<20130804204034.0f96cb80@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754687Ab3HEGhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 02:37:07 -0400
In-Reply-To: <20130804204034.0f96cb80@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 4 Aug 2013 20:40:34 -0700

> The following is needed as well to fix warning/error about shifting a 32 bit
> value 32 bits which occurs if building on 32 bit platform caused by conversion
> to using dma_addr_t
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks.
