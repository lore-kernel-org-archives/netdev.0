From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/6] ppc: Kconfig: Enable BPF JIT on ppc32
Date: Sun, 15 Feb 2015 10:15:54 -0800
Message-ID: <1424024154.2685.1.camel@perches.com>
References: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
	 <1424023605-2416-2-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0073.hostedemail.com ([216.40.44.73]:36716 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754866AbbBOSP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 13:15:58 -0500
In-Reply-To: <1424023605-2416-2-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-02-15 at 21:06 +0300, Denis Kirjanov wrote:
[]
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
[]
> @@ -126,7 +126,7 @@ config PPC
>  	select IRQ_FORCED_THREADING
>  	select HAVE_RCU_TABLE_FREE if SMP
>  	select HAVE_SYSCALL_TRACEPOINTS
> -	select HAVE_BPF_JIT if PPC64
> +	select HAVE_BPF_JIT

trivia:

Should this be the last patch of the series?
