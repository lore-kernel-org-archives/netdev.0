From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [leo@yuriev.ru: [PATCH] ethernet-bridge: update skb->priority
 in case forwarded frame has VLAN-header]
Date: Mon, 7 Mar 2005 10:07:44 -0800
Message-ID: <20050307100744.429e100a@dxpl.pdx.osdl.net>
References: <20050305141225.GA5180@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <20050305141225.GA5180@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Mar 2005 15:12:25 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> ----- Forwarded message from Leo Yuriev <leo@yuriev.ru> -----
> 
> From: Leo Yuriev <leo@yuriev.ru>
> To: Lennert Buytenhek <buytenh@gnu.org>,
> 	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: linux-kernel@vger.kernel.org
> Subject: [PATCH] ethernet-bridge: update skb->priority in case forwarded frame has VLAN-header
> 
> Kernel 2.6 (2.6.11)
> 
> When ethernet-bridge forward a packet and such ethernet-frame has
> VLAN-tag, bridge should update skb->prioriry for properly QoS
> handling.
> 
> This small patch does this. Currently vlan_TCI-priority directly
> mapped to skb->priority, but this looks enough.

I don't see why the VLAN code doesn't handle this itself. I don't like special
case layer violations because it becomes a slippery slope with more and
more additions.
