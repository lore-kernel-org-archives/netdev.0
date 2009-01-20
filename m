From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Tue, 20 Jan 2009 11:40:22 +0100
Message-ID: <20090120104022.GB29346@elte.hu>
References: <20090115183942.GA6325@elte.hu> <200901170827.33729.rusty@rustcorp.com.au> <20090116220832.GB20653@elte.hu> <200901201328.24605.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, tj@kernel.org, hpa@zytor.com,
	brgerst@gmail.com, ebiederm@xmission.com, cl@linux-foundation.org,
	travis@sgi.com, linux-kernel@vger.kernel.org, steiner@sgi.com,
	hugh@veritas.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:51710 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752684AbZATKlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 05:41:02 -0500
Content-Disposition: inline
In-Reply-To: <200901201328.24605.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Rusty Russell <rusty@rustcorp.com.au> wrote:

> On Saturday 17 January 2009 08:38:32 Ingo Molnar wrote:
> > How do difficulties of dynamic percpu-alloc make my above suggestion 
> > unsuitable for SNMP stats in networking? Most of those stats are not 
> > dynamically allocated - they are plain straightforward percpu variables.
> 
> No they're not. [...]

hm, i see this got changed recently - part of the networking stats went 
over to the lib/percpu_counter API recently.

The larger point still remains: the kernel dominantly uses static percpu 
variables by a margin of 10 to 1, so we cannot just brush away the static 
percpu variables and must concentrate on optimizing that side with 
priority. It's nice if the dynamic percpu-alloc side improves as well, of 
course.

	Ingo
