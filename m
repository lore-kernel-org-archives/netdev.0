From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sun, 6 Feb 2005 19:54:17 +0100
Message-ID: <20050206185417.GU31837@postel.suug.ch>
References: <20050128230327.GV31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050128230327.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> NLMSG_GOODSIZE specifies a good default size for the skb tailroom
> used in netlink messages when the size is unknown at the time of
> the allocation.
> 
> The current value doesn't make much sense anymore because
> skb_shared_info isn't taken into account which means that
> depending on the architecture NLMSG_GOOSIZE can exceed PAGE_SIZE
> resulting in a waste of almost a complete page.
> 
> Using SKB_MAXORDER solves this potential leak at the cost of
> slightly smaller but safer sizes for some architectures.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Dave, did you get this one?
