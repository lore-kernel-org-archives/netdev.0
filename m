From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] spidernet : fix memory leak in spider_net_stop
Date: Fri, 02 Feb 2007 08:34:37 -0500
Message-ID: <45C33DED.8010200@garzik.org>
References: <200702011207.47421.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>,
	James K Lewis <jim@jklewis.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48381 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423066AbXBBNfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 08:35:04 -0500
In-Reply-To: <200702011207.47421.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jens Osterkamp wrote:
> We forget to call spider_net_free_rx_chain_contents which does the
> actual dev_kfree_skb. New skbs are allocated from skbuff_head_cache
> on each "ifconfig up" letting the cache grow infinitely.
> 
> This patch fixes it.
> 
> Signed-off-by: Jens Osterkamp <jens@de.ibm.com>

applied

