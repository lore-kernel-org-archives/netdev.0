From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Mon, 29 Sep 2003 22:09:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929220916.19c9c90d.davem@redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	<20030928231842.GE1039@conectiva.com.br>
	<20030928232403.GX15338@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com, pekkas@netcore.fi,
        lksctp-developers@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>
In-Reply-To: <20030928232403.GX15338@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2003 01:24:03 +0200
Adrian Bunk <bunk@fs.tum.de> wrote:

> This is broken since it's legal to compile a module much later than the 
> kernel.

Not in this case.

For things inside the kernel, what ipv6 is doing is completely legal.
Changing your config setting in any way in the main kernel tree can
change just about anything else in the kernel, including the layout
of structures.
