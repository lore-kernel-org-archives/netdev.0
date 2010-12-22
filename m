From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH v4] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 08:13:09 -0500
Message-ID: <1293023589.9820.186.camel@dan>
References: <1292708499.10804.89.camel@dan> <20101222130349.GB13412@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	eparis@parisplace.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101222130349.GB13412@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Hm, why is it off by default? Is there some user-space regression that is caused by 
> this?
> 
> We really want good security measures to be active by default (and to work by 
> default) - they are not worth much if they are not.
> 

I agree entirely, but I've received a lot of resistance to these types
of changes in net.  I'm afraid that if it's enabled by default, no one
will actually allow use of the %pK specifier where it should be used.

As far as I know, there's no actual breakage of anything in userspace,
but there's a general "it might make it harder to debug things in
certain limited circumstances" sentiment among some.  I never understood
why it is necessary for unprivileged users to be able to debug the
kernel.

Does anyone else have thoughts on this?

> Thanks,
> 
> 	Ingo
