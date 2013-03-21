From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: bpf_jit_comp: refactor and unify BPF
 JIT image dump output
Date: Thu, 21 Mar 2013 17:26:17 -0400 (EDT)
Message-ID: <20130321.172617.1445692232036840799.davem@davemloft.net>
References: <1363900923-3244-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mgherzan@gmail.com, matt@ozlabs.org,
	eric.dumazet@google.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3CUV0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:26:18 -0400
In-Reply-To: <1363900923-3244-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 21 Mar 2013 22:22:03 +0100

> If bpf_jit_enable > 1, then we dump the emitted JIT compiled image
> after creation. Currently, only SPARC and PowerPC has similar output
> as in the reference implementation on x86_64. Make a small helper
> function in order to reduce duplicated code and make the dump output
> uniform across architectures x86_64, SPARC, PPC, ARM (e.g. on ARM
> flen, pass and proglen are currently not shown, but would be
> interesting to know as well), also for future BPF JIT implementations
> on other archs.
> 
> Cc: Mircea Gherzan <mgherzan@gmail.com>
> Cc: Matt Evans <matt@ozlabs.org>
> Cc: Eric Dumazet <eric.dumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Thanks for doing this consolidation, applied, thanks Daniel.
