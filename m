From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Wed, 13 Apr 2011 15:22:10 +0400
Message-ID: <20110413112210.GA6948@albatros>
References: <20110412.142534.183049889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: solar@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, peak@argo.troja.mff.cuni.cz,
	kees.cook@canonical.com, dan.j.rosenberg@gmail.com,
	eugene@redhat.com, nelhage@ksplice.com, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110412.142534.183049889.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2011 at 14:25 -0700, David Miller wrote:
> I have no fundamental objections to this change and I'll be happy to
> apply it after we iron out a few details.

Great!

> First, please get rid of the debug option, we have pr_debug() which can
> be dynamically turned on and off at run time these days.

OK.

> Second, if this is a bonafide core facility we'd like everyone to use,
> let's make it so.  I want it so that every ping binary can expect this
> facility to be there if the kernel is new enough.
> 
> So let's get rid of the config option.

OK.

> Finally, longer term, I'd really like to see ipv6 support for this
> feature as well.

Definitely.

For ICMPv6 we should recognize what message types are OK to send by
non-root users and what types are privileged.  We just didn't do this
yet.


Thank you for the review,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
