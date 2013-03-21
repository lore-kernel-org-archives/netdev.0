From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/3] sh_eth: use managed device API
Date: Thu, 21 Mar 2013 17:35:23 -0400 (EDT)
Message-ID: <20130321.173523.2134000966916487176.davem@davemloft.net>
References: <201303220135.51520.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353Ab3CUVfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:35:25 -0400
In-Reply-To: <201303220135.51520.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 22 Mar 2013 01:35:51 +0300

> Switch the driver to the managed device API by replacing ioremap() calls with
> devm_ioremap_resource() (which will also result in calling request_mem_region()
> which the driver forgot to do until now) and k[mz]alloc() with devm_kzalloc() --
> this permits to simplify driver's probe()/remove() method cleanup. We can now
> remove the ioremap() error messages since the error messages are printed by
>  devm_ioremap_resource() itself. We can also remove the 'bitbang' field from
> 'struct sh_eth_private' as we don't need it anymore in order to free the memory
> behind it...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> Changes since initial posting:
> - removed unused 'mdp' variable in sh_eth_drv_remove().
> 
> Sorry, I seem to have missed the unused variable warning... :-/

I already applied your original patch.

Please read your email before posting new versions of patches.

You have to send me a relative fix since your patches are applied
already.
