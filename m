From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 09:26:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064910398.21551.41.camel@hades.cambridge.redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	 <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de>
	 <20030929220916.19c9c90d.davem@redhat.com>
	 <1064903562.6154.160.camel@imladris.demon.co.uk>
	 <20030930000302.3e1bf8bb.davem@redhat.com>
	 <1064907572.21551.31.camel@hades.cambridge.redhat.com>
	 <20030930010855.095c2c35.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, acme@conectiva.com.br, netdev@oss.sgi.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030930010855.095c2c35.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-09-30 at 01:08 -0700, David S. Miller wrote:
> If the user sets CONFIG_IPV6 to 'm' from 'n', and make then creates a
> new kernel image for him (which it will if dependencies are working
> correctly), if he can't figure out that he's gotta install that thing
> maybe he should enable module symbol versions to protect him from
> insmod'ing that ipv6 module by mistake.

Why would he run 'make'? He'll only run 'make modules' since he only
enabled one extra module, and then he expects to be able to load it
without a reboot.

He expects this because it is intuitive ('just a new module') and
because it is true for just about all other modular options in the tree.

> The suggestions I see do nothing to enhance the kernel tree as it currently
> stands.  If you wish to prevent the kernel image from changing due to
> out-of-tree modules being built, fine, but don't impose this restriction
> upon in-kernel modules.

It's a matter of taste. As I said, it's your right to disagree.

Some time during 2.7 I'm sure one of the many people who agree with
Adrian and myself will send patches to Linus and he'll get to arbitrate.

-- 
dwmw2
