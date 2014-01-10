From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: delete non-required instances of include
 <linux/init.h>
Date: Fri, 10 Jan 2014 18:07:22 -0500 (EST)
Message-ID: <20140110.180722.323796634041783146.davem@davemloft.net>
References: <1389213167-720-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbaAJXHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 18:07:23 -0500
In-Reply-To: <1389213167-720-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 8 Jan 2014 15:32:47 -0500

> None of these files are actually using any __init type directives
> and hence don't need to include <linux/init.h>.   Most are just a
> left over from __devinit and __cpuinit removal, or simply due to
> code getting copied from one driver to the next.
> 
> This covers everything under drivers/net except for wireless, which
> has been submitted separately.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
> 
> [build tested drivers/net allyes/modconfig for x86-64, x86, ARM,
>  ppc, sparc on todays net-next - v3.13-rc6-1503-g80077935cad2]

Applied, thanks Paul.
