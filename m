From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 7/7] netpoll: avoid kfree_skb on packets with destructo
Date: Tue, 22 Mar 2005 18:35:21 -0800
Message-ID: <20050322183521.359cd068.davem@davemloft.net>
References: <7.454130102@selenic.com>
	<8.454130102@selenic.com>
	<20050303130031.066f0862.davem@davemloft.net>
	<20050303213228.GU3120@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, jmoyer@redhat.com
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050303213228.GU3120@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Mar 2005 13:32:28 -0800
Matt Mackall <mpm@selenic.com> wrote:

> Doh. Plain as day. How's this look?
> 
> Packets that have destructors should not be zapped here as that might
> produce additional printk warnings via netconsole.
> 
> Signed-off-by: Matt Mackall <mpm@selenic.com>

Looks great Matt, applied.

Thanks.
