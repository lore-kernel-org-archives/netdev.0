From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 6/9] X.25: Stop /proc/net/x25/route infinitely reading
Date: Thu, 28 Oct 2004 16:47:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028164749.58cde95e.davem@davemloft.net>
References: <200410280721.i9S7Li908005@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200410280721.i9S7Li908005@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 00:19:45 -0700
akpm@osdl.org wrote:

> From: Andrew Hendry <ahendry@tusc.com.au>
> 
> route add --x25 0/0 eth0
> cat /proc/net/x25/route
> reads the single routing entry forever.
> 
> This patch makes x25_get_route_idx behave the same as x25_get_socket_idx
> which works correctly.
> 
> Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
