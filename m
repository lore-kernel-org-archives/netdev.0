From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Tcp port selection for IPV6.
Date: Tue, 25 Jan 2005 22:25:08 -0800
Message-ID: <20050125222508.09f49c72.davem@davemloft.net>
References: <20050120164529.6d6a5f0b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050120164529.6d6a5f0b@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 16:45:29 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch makes TCP over IPV6 select ports the same way the current
> TCPv4 code does. It uses a hash function to provide a starting offset
> and a free running counter to provide seed.
> 
> This changes the port selection semantics to match TCPv4 as well.
> If the port is in use but to a different remote address, it will get
> reused. It looks like the TCPv6 code was not updated when the TCPv4
> code changed. Now the code in ipv4/tcp_ipv4.c and ipv6/tcp_ipv6.c are
> almost identical for tcp_hash_connect.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Looks good, sorry for taking so long to review.

I think I'll push this into my 2.6.12 pending queue since 2.6.11
is very much in a bug-fix-only type mode.
