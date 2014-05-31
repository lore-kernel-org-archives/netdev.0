From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] sfc: Restrict PIO for 64bit arch in order
 to avoid data corruption
Date: Fri, 30 May 2014 17:38:20 -0700 (PDT)
Message-ID: <20140530.173820.494414338220972060.davem@davemloft.net>
References: <5385AAF5.7090001@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934624AbaEaAiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 20:38:21 -0400
In-Reply-To: <5385AAF5.7090001@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 28 May 2014 10:23:01 +0100

> This patch series 
> Fixes: ee45fd92c739db5b7950163d91dfe5f016af6d24
> 
> The linux net driver uses memcpy_toio() in order to copy into
> the PIO buffers.
> Even on a 64bit machine this causes 32bit accesses to a write-
> combined memory region.
> There are hardware limitations that mean that only
> 64bit naturally aligned accesses are safe in all cases. Due to being
> write-combined memory region two 32bit accesses may be coalesced to
> form a 64bit non 64bit aligned access.
> Solution was to open-code the memory copy routines using pointers
> and to only enable PIO for x86_64 machines.
> 
> This bug fix applies to v3.13 and v3.14 stable branches.

You submited this twice and I'm still confused which ones I should
use.

Please resubmit this and address Sergei's feedback, thank you.
