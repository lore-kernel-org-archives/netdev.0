From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Wed, 9 Mar 2005 20:49:47 -0800
Message-ID: <20050309204947.2618d278.davem@davemloft.net>
References: <4217266F.6090700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4217266F.6090700@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Feb 2005 12:43:43 +0100
Patrick McHardy <kaber@trash.net> wrote:

> The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
> of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
> type and code should be stored in sport and dport, in struct flowi both
> are contained in fl_ip_sport.

This resulted in a long thread, many newer versions of the patch
trying to clean this up in other ways, but then we determined that
this original patch was the best and safest fix for now.

So I applied this first patch.

Thanks everyone.
