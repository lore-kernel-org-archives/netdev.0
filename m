From: Andrew Morton <akpm@digeo.com>
Subject: Re: Route cache performance under stress
Date: Fri, 23 May 2003 17:41:56 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030523174156.210d7f94.akpm@digeo.com>
References: <20030520.173607.88482742.davem@redhat.com>
	<20030522084003.GA22613@netnation.com>
	<20030522.015815.91322249.davem@redhat.com>
	<20030522.034058.71558626.davem@redhat.com>
	<1053602138.9475.34.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1053602138.9475.34.camel@tux.rsn.bth.se>
List-Id: netdev.vger.kernel.org

Martin Josefsson <gandalf@wlug.westbo.se> wrote:
>
> Any reason you're not using get_order() ?

hm.

a) mips64 and cris seem to have forgotten to implement it.

b) ppc and ia64 just had to sneak a bit of asm into their version

c) all other architectures did a copy-n-paste.


I get the feeling that we need just a single copy of this guy, in
<linux/bitops.h>


