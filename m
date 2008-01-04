From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: prot_inuse cleanups and optimizations
Date: Thu, 03 Jan 2008 20:47:05 -0800 (PST)
Message-ID: <20080103.204705.35413740.davem@davemloft.net>
References: <20080103184154.220b5294.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@redhat.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33051
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753956AbYADErG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 23:47:06 -0500
In-Reply-To: <20080103184154.220b5294.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 3 Jan 2008 18:41:54 +0100

> 1) Cleanups (all functions are prefixed by sock_prot_inuse)
> 
> sock_prot_inc_use(prot) -> sock_prot_inuse_add(prot,-1)
> sock_prot_dec_use(prot) -> sock_prot_inuse_add(prot,-1)
> sock_prot_inuse()       -> sock_prot_inuse_get()
> 
> New functions :
> 
> sock_prot_inuse_init() and sock_prot_inuse_free() to abstract pcounter use.
> 
> 2) if CONFIG_PROC_FS=n, we can zap 'inuse' member from "struct proto",
> since nobody wants to read the inuse value.
> 
> This saves 1372 bytes on i386/SMP and some cpu cycles.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I hate the ifdef, but it's in a header so what can I do? :-)

Applied, thanks Eric.
