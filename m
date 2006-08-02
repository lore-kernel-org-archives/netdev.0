From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Fix more per-cpu typos
Date: Wed, 2 Aug 2006 19:26:44 +0400
Message-ID: <20060802152644.GB6827@martell.zuzino.mipt.ru>
References: <20060801232333.GC14863@martell.zuzino.mipt.ru> <200608020502.11274.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:49647 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751196AbWHBP0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 11:26:50 -0400
Received: by nf-out-0910.google.com with SMTP id o25so671543nfa
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2006 08:26:49 -0700 (PDT)
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200608020502.11274.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 02, 2006 at 05:02:11AM +0200, Andi Kleen wrote:
> > --- a/arch/x86_64/kernel/smp.c
> > +++ b/arch/x86_64/kernel/smp.c
> > @@ -203,7 +203,7 @@ int __cpuinit init_smp_flush(void)
> >  {
> >  	int i;
> >  	for_each_cpu_mask(i, cpu_possible_map) {
> > -		spin_lock_init(&per_cpu(flush_state.tlbstate_lock, i));
> > +		spin_lock_init(&per_cpu(flush_state, i).tlbstate_lock);
>
> What advantage does this have over the earlier form?

I've grepped tree after seeing "[PATCH] fix vmstat per cpu usage"=B9.
Rationale mentioned in that thread are
1) invalid asm on s390
2) it only works because per-cpu macros are very simple

> In general this should be split up into three patches.

Yep, I see Andrew splitted them.

=B9 http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=3D115445399826223&=
w=3D2

