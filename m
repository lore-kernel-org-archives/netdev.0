From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Fix more per-cpu typos
Date: Wed, 2 Aug 2006 05:02:11 +0200
Message-ID: <200608020502.11274.ak@suse.de>
References: <20060801232333.GC14863@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:32649 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751091AbWHBDKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 23:10:14 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060801232333.GC14863@martell.zuzino.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> --- a/arch/x86_64/kernel/smp.c
> +++ b/arch/x86_64/kernel/smp.c
> @@ -203,7 +203,7 @@ int __cpuinit init_smp_flush(void)
>  {
>  	int i;
>  	for_each_cpu_mask(i, cpu_possible_map) {
> -		spin_lock_init(&per_cpu(flush_state.tlbstate_lock, i));
> +		spin_lock_init(&per_cpu(flush_state, i).tlbstate_lock);

What advantage does this have over the earlier form?

In general this should be split up into three patches.

-Andi
