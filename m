From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Sun, 30 Jan 2005 21:11:50 -0800
Message-ID: <20050130211150.464d1c62.davem@davemloft.net>
References: <41FD2043.3070303@trash.net>
	<E1CvSuS-00056x-00@gondolin.me.apana.org.au>
	<20050131.134559.125426676.yoshfuji@linux-ipv6.org>
	<41FDBB78.2050403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, herbert@gondor.apana.org.au,
        rmk+lkml@arm.linux.org.uk, Robert.Olsson@data.slu.se, akpm@osdl.org,
        torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41FDBB78.2050403@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005 06:00:40 +0100
Patrick McHardy <kaber@trash.net> wrote:

> We don't need this for IPv6 yet. Once we get nf_conntrack in we
> might need this, but its IPv6 fragment handling is different from
> ip_conntrack, I need to check first.

Right, ipv6 netfilter cannot create this situation yet.

However, logically the fix is still correct and I'll add
it into the tree.
