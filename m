From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] 8139cp: Improve accuracy of cp_interrupt() return,
 to survive IRQ storms
Date: Wed, 23 Sep 2015 14:48:08 -0700 (PDT)
Message-ID: <20150923.144808.886375927698238398.davem@davemloft.net>
References: <1442996049.36485.32.camel@infradead.org>
	<20150923.105812.149257816141624869.davem@davemloft.net>
	<1443037530.74600.29.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbbIWVsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:48:09 -0400
In-Reply-To: <1443037530.74600.29.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 23 Sep 2015 20:45:30 +0100

> Since you explicitly call them 'bug fixes'... I suppose the last patch
> in the latest series (enabling the various offloads by default) isn't a
> bug fix and should be held back for net-next.
> 
> I think I can live with pushing the rest for the net tree. Just to
> recap, the series is:

I've applied patches #1-#6 and left #7 sitting around in patchwork
for when I next merge net into net-next, thanks.
