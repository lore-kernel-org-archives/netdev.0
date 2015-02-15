From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] ppc: Kconfig: Enable BPF JIT on ppc32
Date: Sun, 15 Feb 2015 11:07:29 -0800 (PST)
Message-ID: <20150215.110729.1985006476906451021.davem@davemloft.net>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
	<1424023605-2416-2-git-send-email-kda@linux-powerpc.org>
	<1424024154.2685.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932142AbbBOTAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 14:00:22 -0500
In-Reply-To: <1424024154.2685.1.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 15 Feb 2015 10:15:54 -0800

> On Sun, 2015-02-15 at 21:06 +0300, Denis Kirjanov wrote:
> []
>> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> []
>> @@ -126,7 +126,7 @@ config PPC
>>  	select IRQ_FORCED_THREADING
>>  	select HAVE_RCU_TABLE_FREE if SMP
>>  	select HAVE_SYSCALL_TRACEPOINTS
>> -	select HAVE_BPF_JIT if PPC64
>> +	select HAVE_BPF_JIT
> 
> trivia:
> 
> Should this be the last patch of the series?

Yes, that's the way I see it too.
