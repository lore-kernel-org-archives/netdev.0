From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: [PATCH 39] net/ipv4/ip_options.c: kmalloc + memset conversion to kzalloc
Date: Tue, 31 Jul 2007 23:15:57 +0200
Message-ID: <200707312315.58399.m.kozlowski@tuxland.pl>
References: <200707311845.48807.m.kozlowski@tuxland.pl> <200707312016.59970.m.kozlowski@tuxland.pl> <20070731.140728.118970012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:1933 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbXGaVP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 17:15:59 -0400
In-Reply-To: <20070731.140728.118970012.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Applied, but note that this patch changes behavior, previously
> only the ip_options structure base was cleared out, but now
> the whole memory region is cleared.
> 
> I think it's OK for this case, but I'm just making note of it.

Agrh. Sorry. I must have overlook this. Feel free to drop it if
you think its not worth it :-)

Thanks,

	Mariusz
