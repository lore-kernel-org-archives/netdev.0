From: "David S. Miller" <davem@redhat.com>
Subject: Re: Are IPV6 module ref counts wrong on 2.6.0-test11?
Date: Wed, 10 Dec 2003 12:49:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210124948.042a3a5f.davem@redhat.com>
References: <20031210120309.09b8fd84.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031210120309.09b8fd84.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2003 12:03:09 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> If I load IPV6 as a module, it comes up with a ref count of 10
> even though there are no applications using IPV6.
> 
> Interesting /proc/net/sockstat6 shows 1 TCP connection, but there is
> no application with that open.
> 
> This doesn't seem right, and it makes unloading IPV6 impossible.

IPV6 is not safe to unload as a module, it is going to take
a lot of difficult work to fix this.

The 10 reference counts come from things like sockets created for
sending ipv6 ICMP packets and stuff like that.
