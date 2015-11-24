From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 23:45:08 +0100
Message-ID: <20151124224508.GE23215@breakpoint.cc>
References: <20151124205537.GC23215@breakpoint.cc>
 <CALx6S36oFH9=Px=pptZurWgS1MtFbhOE=FeK0jZmNBk3fU7tSg@mail.gmail.com>
 <20151124222242.GD23215@breakpoint.cc>
 <20151124.172547.672210919260359472.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, tom@herbertland.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, kernel-team@fb.com, davejwatson@fb.com,
	alexei.starovoitov@gmail.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60266 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932109AbbKXWpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 17:45:14 -0500
Content-Disposition: inline
In-Reply-To: <20151124.172547.672210919260359472.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@redhat.com> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Tue, 24 Nov 2015 23:22:42 +0100
> 
> > Yes, I get that point, but I maintain that KCM is a strange workaround
> > for bad userspace design.
> 
> I fundamentally disagree with you.

Fair enough.  Still, I do not see how what KCM intends to do
can be achieved while at the same time imposing some upper bound on
the amount of kernel memory we can allocate globally and per socket.

Once such limit would be enforced the question becomes how the kernel
could handle such an error other than via close of the underlying tcp
connection.

Not adding any limit is not a good idea in my opinion.
