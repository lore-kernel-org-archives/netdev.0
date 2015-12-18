From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ila: add NETFILTER dependency
Date: Fri, 18 Dec 2015 14:19:48 -0500 (EST)
Message-ID: <20151218.141948.2267406136595226362.davem@davemloft.net>
References: <2011239.T7zzuZGeyk@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, tom@herbertland.com,
	netfilter-devel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932736AbbLRTTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 14:19:50 -0500
In-Reply-To: <2011239.T7zzuZGeyk@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 18 Dec 2015 15:37:37 +0100

> The recently added generic ILA translation facility fails to
> build when CONFIG_NETFILTER is disabled:
> 
> net/ipv6/ila/ila_xlat.c:229:20: warning: 'struct nf_hook_state' declared inside parameter list
> net/ipv6/ila/ila_xlat.c:235:27: error: array type has incomplete element type 'struct nf_hook_ops'
>  static struct nf_hook_ops ila_nf_hook_ops[] __read_mostly = {
> 
> This adds an explicit Kconfig dependency to avoid that case.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 7f00feaf1076 ("ila: Add generic ILA translation facility")

Applied, thanks.
