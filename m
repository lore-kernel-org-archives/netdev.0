From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-net] drivers/net: fix build warning in ethernet/sfc/tx.c
Date: Thu, 06 Feb 2014 22:29:48 -0800 (PST)
Message-ID: <20140206.222948.1368580724494519398.davem@davemloft.net>
References: <1391705112-27869-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jcooper@solarflare.com, bhutchings@solarflare.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbaBGG3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 01:29:49 -0500
In-Reply-To: <1391705112-27869-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 6 Feb 2014 11:45:12 -0500

> Commit ee45fd92c739db5b7950163d91dfe5f016af6d24 ("sfc: Use TX PIO
> for sufficiently small packets") introduced the following warning:
> 
> drivers/net/ethernet/sfc/tx.c: In function 'efx_enqueue_skb':
> drivers/net/ethernet/sfc/tx.c:432:1: warning: label 'finish_packet' defined but not used
> 
> Stick the label inside the same #ifdef that the code which calls
> it uses.  Note that this is only seen for arch that do not set
> ARCH_HAS_IOREMAP_WC, such as arm, mips, sparc, ..., as the others
> enable the write combining code and hence use the label.
> 
> Cc: Jon Cooper <jcooper@solarflare.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
