From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 01:30:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930013025.697c786e.davem@redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	<20030928231842.GE1039@conectiva.com.br>
	<20030928232403.GX15338@fs.tum.de>
	<20030929220916.19c9c90d.davem@redhat.com>
	<1064903562.6154.160.camel@imladris.demon.co.uk>
	<20030930000302.3e1bf8bb.davem@redhat.com>
	<1064907572.21551.31.camel@hades.cambridge.redhat.com>
	<20030930010855.095c2c35.davem@redhat.com>
	<1064910398.21551.41.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, acme@conectiva.com.br, netdev@oss.sgi.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1064910398.21551.41.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Sep 2003 09:26:38 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

> Why would he run 'make'? He'll only run 'make modules' since he only
> enabled one extra module, and then he expects to be able to load it
> without a reboot.

If 'make modules' doesn't check if the config change has hit a
dependency that requires the core kernel image to be rebuilt, we need
to fix that.  'make modules' depends upon the kernel image.

At the very least, it should refuse to build the modules and tell the
user what he needs to do first.

All you've shown me is a bug in the build system, not a fundamental
issue with module enables creating changes to the main kernel image.
