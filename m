From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Tue, 7 Jul 2009 17:44:40 +0200
Message-ID: <20090707154440.GA15605@redhat.com>
References: <4A4DCD54.1080908@gmail.com> <20090703092438.GE3902@elte.hu> <20090703095659.GA4518@jolsa.lab.eng.brq.redhat.com> <20090703102530.GD32128@elte.hu> <20090703111848.GA10267@jolsa.lab.eng.brq.redhat.com> <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal> <20090707143416.GB11704@redhat.com> <20090707150406.GC7124@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Olsa <jolsa@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, davidel@xmailserver.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33971 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756151AbZGGPrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 11:47:51 -0400
Content-Disposition: inline
In-Reply-To: <20090707150406.GC7124@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07, Mathieu Desnoyers wrote:
>
> Actually, thinking about it more, to appropriately support x86, as well
> as powerpc, arm and mips, we would need something like:
>
> read_lock_smp_mb()
>
> Which would be a read_lock with an included memory barrier.

Then we need read_lock_irq_smp_mb, read_lock_irqsave__smp_mb, write_lock_xxx,
otherwise it is not clear why only read_lock() has _smp_mb() version.

The same for spin_lock_xxx...

Oleg.

