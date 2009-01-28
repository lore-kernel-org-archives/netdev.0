From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: wrong test in inet_ehash_locks_alloc()
Date: Tue, 27 Jan 2009 17:45:19 -0800 (PST)
Message-ID: <20090127.174519.136722631.davem@davemloft.net>
References: <497F1D46.70103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55109
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751987AbZA1BpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 20:45:21 -0500
In-Reply-To: <497F1D46.70103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 27 Jan 2009 15:42:14 +0100

> In commit 9db66bdcc83749affe61c61eb8ff3cf08f42afec
> (net: convert TCP/DCCP ehash rwlocks to spinlocks), I forgot to change
>  one occurrence of rwlock_t to spinlock_t
> 
> I believe sizeof(raw_spinlock_t) might be > 0 on !CONFIG_SMP if CONFIG_DEBUG_SPINLOCK
> while sizeof(raw_rwlock_t) should be 0 in this case.
> 
> Fortunatly, CONFIG_DEBUG_SPINLOCK adds fields to both spinlock_t and rwlock_t,
> but at this might change in the future (being able to debug spinlocks but not rwlocks for
> example), better to be safe.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Agreed, applied.

Thanks Eric.
