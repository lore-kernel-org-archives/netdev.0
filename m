From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] (4/4) bridge: forwarding table lockless update
Date: Thu, 10 Mar 2005 18:51:52 -0800
Message-ID: <20050310185152.12ed9819.davem@davemloft.net>
References: <20050310154437.1223b6e9@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@lists.osdl.org
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050310154437.1223b6e9@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 15:44:37 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Optimize bridge forwarding table for the fastpath of updating
> an existing entry. Use RCU to find the entry and change it's time.
> Fallback to normal locking for insert. This gives about a 1/3
> improvement in packets forwarding per second on SMP.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks.
