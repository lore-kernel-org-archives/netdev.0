From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] samples: bpf: enable trace samples for s390x
Date: Wed, 08 Jul 2015 15:17:56 -0700 (PDT)
Message-ID: <20150708.151756.1666783399572467734.davem@davemloft.net>
References: <20150706162007.69824718@holzheu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, netdev@vger.kernel.org
To: holzheu@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbbGHWR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 18:17:57 -0400
In-Reply-To: <20150706162007.69824718@holzheu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Date: Mon, 6 Jul 2015 16:20:07 +0200

> The trace bpf samples do not compile on s390x because they use x86
> specific fields from the "pt_regs" structure.
> 
> Fix this and access the fields via new PT_REGS macros.
> 
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>

Applied to net-next, thanks.
