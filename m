From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v4] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 14:03:49 +0100
Message-ID: <20101222130349.GB13412@elte.hu>
References: <1292708499.10804.89.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	eparis@parisplace.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1292708499.10804.89.camel@dan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Dan Rosenberg <drosenberg@vsecurity.com> wrote:

> +kptr_restrict:
> +
> +This toggle indicates whether restrictions are placed on
> +exposing kernel addresses via /proc and other interfaces.  When
> +kptr_restrict is set to (0), the default, there are no
> +restrictions.  When kptr_restrict is set to (1), kernel pointers
> +printed using the %pK format specifier will be replaced with 0's
> +unless the user has CAP_SYSLOG.  When kptr_restrict is set to
> +(2), kernel pointers printed using %pK will be replaced with 0's
> +regardless of privileges.

Hm, why is it off by default? Is there some user-space regression that is caused by 
this?

We really want good security measures to be active by default (and to work by 
default) - they are not worth much if they are not.

Thanks,

	Ingo
