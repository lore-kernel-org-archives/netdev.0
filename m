From: David Brownell <david-b@pacbell.net>
Subject: Re: netlink tester program
Date: Mon, 02 Jun 2003 18:56:23 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EDC0047.7030007@pacbell.net>
References: <32804.4.64.196.31.1054351332.squirrel@www.osdl.org>	<20030530.234211.102567405.davem@redhat.com>	<20030602140452.039248de.rddunlap@osdl.org> <20030602.145619.71112623.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rddunlap@osdl.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: "Randy.Dunlap" <rddunlap@osdl.org>
>    Date: Mon, 2 Jun 2003 14:04:52 -0700
> 
>    Does anyone have documentation (or semantics) for rtnl_talk()?
>    or just some blurb about it?
> 
> I always have to wonder about someone who can't live with just
> working code to study, and absolutely requires some document
> describing it.
> 
> What is better or more accurate description than code itself!?!?!

Well, the difference between code and its spec is
generally a bug that needs to be fixed ... which
can be in the code as well as in the spec.  And for
reasonable design specs, it's more likely in the code.

But if there's only the code, it gets a lot more
troublesome when things don't behave "as expected".

People who are in a position to change the code
to meet their expectations may not care, but that's
rarely a significant chunk of the user community.

And in particular, writing tests against the code
is generally the wrong way to go.  They need to be
written against some kind of spec.

- Dave



