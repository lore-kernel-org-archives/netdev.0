From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] optimize is_valid_ether_addr
Date: Thu, 10 Mar 2005 18:52:46 -0800
Message-ID: <20050310185246.6b626480.davem@davemloft.net>
References: <20050310154439.75f62f22@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050310154439.75f62f22@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 15:44:39 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Low level optimization of the comparison with zero address.
> On most cpu's faster to use unrolled or rather than a loop
> and memcmp. This is in the fastpath of bridge forwarding.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
