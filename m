From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Thu, 31 Mar 2005 20:36:05 -0800
Message-ID: <20050331203605.3b662f43.davem@davemloft.net>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050329152110.38d50653@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Mar 2005 15:21:10 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Netem has a private queue for delayed packets, and currently, packets
> in this queue are not accounted for in the qdisc qlen statistics.
> This is a problem if netem is used inside another qdisc doing rate
> control that peeks at the qlen.
> 
> This patch changes the statistics to include the packets held but
> not ready to send.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Both 2.4.x and 2.6.x variants applied, thanks Stephen.
