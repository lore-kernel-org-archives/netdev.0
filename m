From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH v2] netfilter: save the hash of the tuple in the
	original direction for latter use
Date: Fri, 20 Aug 2010 09:43:14 -0400
Message-ID: <20100820134314.GA3283@Krystal>
References: <1282228389-3029-1-git-send-email-xiaosuo@gmail.com> <20100819152149.GA19744@Krystal> <AANLkTim5wn0Y-+081gvm7FkWx3NioRvtRMWy2uF4nji2@mail.gmail.com> <1282232786.2549.60.camel@edumazet-laptop> <20100819161112.GA24357@Krystal> <AANLkTinA3-KMPKJa-66QCMUpbDFwey2mjE=VN=9=zg=6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts40.bellnexxia.net ([209.226.175.97]:42370 "EHLO
	tomts40-srv.bellnexxia.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751642Ab0HTNs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 09:48:29 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinA3-KMPKJa-66QCMUpbDFwey2mjE=VN=9=zg=6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ executive summary: trying to explain why static variable declarations
  within the body of functions is bad in kernel code. ]

* Changli Gao (xiaosuo@gmail.com) wrote:
> On Fri, Aug 20, 2010 at 12:11 AM, Mathieu Desnoyers
> <mathieu.desnoyers@polymtl.ca> wrote:
> >
> > Ah, I see. But I think the static variable should stay declared outside
> > of the function scope, with a nice comment explaining why it's not
> > initialized at init-time.
> >
> > Hiding global state in function code is usually frowned upon.
> >
> 
> I don't agree with you. We'd better not expose the variable which
> isn't expected to be used by others. If not, maybe someone will misuse
> it.

We are talking about a static variable usable only within a single file,
where is the problem ? A nice comment can have this effect.

> The user should only reply on the interface, but not the internal
> implementation.

I'm talking about good practice to help code review. This is way more
important than the potential "encapsulation" benefit of hiding global
state (a static variable) within the body of a function.

I remember that Andrew Morton has strong opinions about this, and I
remember being in complete agreement with him on the topic.

Thanks,

Mathieu

> 
> Thanks.
> 
> -- 
> Regards,
> Changli Gao(xiaosuo@gmail.com)

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
