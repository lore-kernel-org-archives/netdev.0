From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 07:32:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064903562.6154.160.camel@imladris.demon.co.uk>
References: <20030928225941.GW15338@fs.tum.de>
	 <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de>
	 <20030929220916.19c9c90d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@fs.tum.de>, acme@conectiva.com.br, netdev@oss.sgi.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030929220916.19c9c90d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-09-29 at 22:09 -0700, David S. Miller wrote:
> For things inside the kernel, what ipv6 is doing is completely legal.
> Changing your config setting in any way in the main kernel tree can
> change just about anything else in the kernel, including the layout
> of structures.

With boolean options that's fair enough. But changing any config option
from 'n' to 'm' should not change anything in the main kernel. To do so
is confusing and should be considered broken, as Adrian says.

-- 
dwmw2
