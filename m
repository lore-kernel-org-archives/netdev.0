From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 08:39:33 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064907572.21551.31.camel@hades.cambridge.redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	 <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de>
	 <20030929220916.19c9c90d.davem@redhat.com>
	 <1064903562.6154.160.camel@imladris.demon.co.uk>
	 <20030930000302.3e1bf8bb.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, acme@conectiva.com.br, netdev@oss.sgi.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030930000302.3e1bf8bb.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-09-30 at 00:03 -0700, David S. Miller wrote:
> This conflicts with the other reply you've made to me in this
> thread where you say that you agree with me.
> 
> So which is it? :-)

Sorry, I was having a laugh. It amused me to demonstrate how a single
apostrophe, or lack of it, can entirely change the meaning of a
sentence. I didn't expect you personally to fall for it -- I expected
you to give me more credit than to assume I'd make kindergarten errors
in a two-word email. 

Read it again, only this time bear in mind I'm a native English speaker
with an IQ over 50 :)

> I don't see why "enabling to 'y'" and "enabling to 'm'" are in any
> way fundamentally different.  You're turning something on, therefore
> something is going to change.

And you don't see why it's confusing that turning something on as a
_module_ changes the contents of the kernel image?

99% or more of tristate options can be enabled without affecting the
kernel, and it is expected that such options can be set to 'm' later,
while the kernel in question is actually running, then built and loaded
without a reboot.

We should strive to keep this true.

> And when I see suggestions that we add four options to replace the
> single one we have now, with a addendum saying "it's not really
> complex, we'll explain it in the documentation", I want to pull my
> hair out.

It was two options, giving four potential combinations. They were
simple:

	Allow this kernel to ever support IPv6? Y/N
	Build IPv6 support? Y/M/N


-- 
dwmw2
