From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] gc_min_interval in milleseconds via /proc (fwd)
Date: Wed, 2 Feb 2005 13:09:36 -0800
Message-ID: <20050202130936.4b3b8895.davem@davemloft.net>
References: <16888.56016.608929.340640@robur.slu.se>
	<20050130225627.4feecd2e.davem@davemloft.net>
	<16894.29281.293401.832567@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16894.29281.293401.832567@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005 19:01:05 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> David S. Miller writes:
> 
>  > We must pick a new sysctl number too, for sysctl() system call.
>  > If the only access possible were through /proc then yes your
>  > change would be valid, but due to sysctl() system call the
>  > .ctl_name defines that dimension of the sysctl namespace.
> 
>  Ok!
>  NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS was added last in list to avoid
>  renumbering. Feel free to change.

Applied, thanks Robert.
