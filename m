From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: add optimized generic percpu accessors
Date: Wed, 21 Jan 2009 14:52:46 +0900
Message-ID: <4976B82E.1080002@kernel.org>
References: <20090115183942.GA6325@elte.hu> <200901170827.33729.rusty@rustcorp.com.au> <20090116220832.GB20653@elte.hu> <200901201328.24605.rusty@rustcorp.com.au> <20090120104022.GB29346@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	akpm@linux-foundation.org, hpa@zytor.com, brgerst@gmail.com,
	ebiederm@xmission.com, cl@linux-foundation.org, travis@sgi.com,
	linux-kernel@vger.kernel.org, steiner@sgi.com, hugh@veritas.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:37623 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755673AbZAUFxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2009 00:53:14 -0500
In-Reply-To: <20090120104022.GB29346@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> The larger point still remains: the kernel dominantly uses static percpu 
> variables by a margin of 10 to 1, so we cannot just brush away the static 
> percpu variables and must concentrate on optimizing that side with 
> priority. It's nice if the dynamic percpu-alloc side improves as well, of 
> course.

Well, the infrequent usage of dynamic percpu allocation is in some
part due to the poor implementation, so it's sort of chicken and egg
problem.  I got into this percpu thing because I wanted a percpu
reference count which can be dynamically allocated and it sucked.

Thanks.

-- 
tejun
